class KmeansClusteringService

  attr_reader :bounding_box

  def initialize(bounding_box)
    @bounding_box = bounding_box
    @rgeo_factory = RGeo::Geos.factory
    @wkb_parser = RGeo::WKRep::WKBParser.new(@rgeo_factory, support_ewkb: true)
  end

  def kmeans_clusters(max_clusters_per_partition, partition_by_column_name = nil)
    clusters = RecentReport.connection.execute(kmeans_query(max_clusters_per_partition, partition_by_column_name))
    format_clusters(clusters)
  end

  def column_names_clusters(*column_names)
    clusters = RecentReport.connection.execute(column_names_cluster_query(*column_names))
    format_clusters(clusters)
  end

  protected

  def column_names_cluster_query(*column_names)
    %Q{
      SELECT #{merge_column_names(*column_names)}, COUNT(*) AS total, ST_Centroid(ST_Collect(location::GEOMETRY)) AS centroid
      FROM recent_reports
      WHERE location && #{make_envelope}
      GROUP BY #{merge_column_names(*column_names)};
    }
  end

  def kmeans_query(means, partition_by_column_name)
    kmeans_function = "kmeans(ARRAY[longitude, latitude], #{means}) OVER (#{partition_by(partition_by_column_name)})"

    %Q{
      SELECT #{merge_column_names(partition_by_column_name, 'kmeans', 'COUNT(*) AS total', 'ST_Centroid(ST_Collect(location::GEOMETRY)) AS centroid')}
      FROM (
        SELECT #{merge_column_names(kmeans_function, 'location', partition_by_column_name)}
        FROM (
          SELECT #{merge_column_names('location', 'latitude', 'longitude', partition_by_column_name)}
          FROM #{RecentReport.table_name}
          WHERE location && #{make_envelope}
        ) cd
      ) ksub
      GROUP BY #{merge_column_names(partition_by_column_name, 'kmeans')}
      ORDER BY #{merge_column_names(partition_by_column_name, 'kmeans')};
    }
  end

  def partition_by(column_name)
    column_name ? "PARTITION BY #{column_name}" : ''
  end

  def merge_column_names(*column_names)
    first = true
    query = ''
    column_names.each do |column_name|
      if column_name
        query << ', ' unless first
        query << column_name
        first = false
      end
    end
    query
  end

  def make_envelope
    "ST_MakeEnvelope(#{@bounding_box[:south_west][:lng]}, #{@bounding_box[:south_west][:lat]}, #{@bounding_box[:north_east][:lng]}, #{@bounding_box[:north_east][:lat]}, 4326)"
  end

  def format_clusters(clusters)
    clusters.map do |cluster|
      centroid = @wkb_parser.parse(cluster['centroid'])

      new_cluster = {}
      new_cluster[:kmeans] = cluster['kmeans'].to_i if cluster.has_key?('kmeans')
      new_cluster[:country] = cluster['country'] if cluster.has_key?('country')
      new_cluster[:state] = cluster['state'] if cluster.has_key?('state')
      new_cluster[:city] = cluster['city'] if cluster.has_key?('city')
      new_cluster[:violent] = ActiveRecord::Type::Boolean.new.type_cast_from_user(cluster['violent']) if cluster.has_key?('violent')
      new_cluster[:latitude] = centroid.y
      new_cluster[:longitude] = centroid.x
      new_cluster[:total] = cluster['total'].to_i
      OpenStruct.new(new_cluster)
    end
  end
end
