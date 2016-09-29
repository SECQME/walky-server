class Line < ActiveRecord::Base
  self.table_name = "osm_2po_4pgr"

  def self.find_by_nearest(latitude, longitude, options = { max: 10 })
    options[:inner_max] = options[:max] * 5 unless options[:inner_max]

    # Read http://boundlessgeo.com/2011/09/indexed-nearest-neighbour-search-in-postgis/
    where("id IN (
      WITH index_query AS (
        SELECT id,
          ST_Distance(
            geom_way,
            ST_SetSRID(ST_MakePoint(:longitude, :latitude), 4326)
          ) as distance
        FROM #{Line.table_name}
        ORDER BY
          geom_way <#> ST_SetSRID(ST_MakePoint(:longitude, :latitude), 4326)
        LIMIT :inner_max
      )
      SELECT id FROM index_query ORDER BY distance LIMIT :max
    )", {
      latitude: latitude,
      longitude: longitude,
      inner_max: options[:inner_max],
      max: options[:max]
    })
  end

  def self.find_by_ordered_ids(*array)
    options = {}
    options = array.pop if array.last.is_a? Hash
    # pass an Array or a list of id arguments
    array = array.flatten if array.first.is_a? Array
    find(array).sort_by { |r| array.index(r.id) }
  end
end
