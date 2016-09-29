class Api::V2::ReportsController < BaseApiController
  respond_to :json

  # GET /reports
  # e.g: /reports?bounds=41.835345,-87.623239|41.839009,-87.618085&zoom_level=12
  def index
    @zoom_level = params[:zoom_level].to_i
    @sw_lat, @sw_lng, @ne_lat, @ne_lng = params[:bounds].split(/[,|]/, 4).map { |e| e.to_f  }
    @per_page = (params[:per_page] || 25).to_i
    @page = (params[:page] || 1).to_i

    @clustering_service = KmeansClusteringService.new(south_west: { lat: @sw_lat, lng: @sw_lng }, north_east: { lat: @ne_lat, lng: @ne_lng })

    case @zoom_level
    when 0..1
      @clusters = @clustering_service.column_names_clusters('country')
      @reports = []
    when 2..4
      @clusters = @clustering_service.column_names_clusters('country', 'state')
      @reports = []
    when 5..9
      @clusters = @clustering_service.column_names_clusters('country', 'state', 'city')
      @reports = []
    when 10
      @clusters = @clustering_service.kmeans_clusters(9)
      @reports = []
    when 11..12
      @clusters = @clustering_service.kmeans_clusters(12)
      @reports = []
    when 13..16
      @clusters = @clustering_service.kmeans_clusters(16)
      @reports = []
    else
      @clusters = []

      @total_reports = find_reports.count
      @reports = find_reports.limit(@per_page).offset((@page - 1) * @per_page)
    end

    if @clusters.length > 1
      recluster_with_hierachical
      convert_clusters_with_single_report
    end

    # Calculate total pages and make sure it has minimum value 1
    @total_reports ||= 0
    @total_pages = (@total_reports / @per_page).floor
    @total_pages = 1 if @total_pages < 1

    response.headers['X-Page'] = @page
    response.headers['X-Per-Page'] = @per_page
    response.headers['X-Total-Pages'] = @total_pages
    response.headers['X-Total-Count'] = @total_reports

    respond_with @reports
  end

  # POST /reports
  def create
    @report = Report.new(report_params)
    @report.location = "POINT(#{report_params['longitude']} #{report_params['latitude']})"
    @report.user = current_user
    @report.save

    RecentReport.refresh if @report.report_category.violent?

    respond_with @report
  end

  def heartbeat
    @report = Report.first
    render json: { "ping" => "pong" }
  end

  private
    def report_params
      params.permit(
        :description,
        :report_time,
        :report_category_id,
        :latitude,
        :longitude,
        :street_name,
        :city,
        :state,
        :country,
        :postcode,
        :invisible
      )
    end

    def find_reports
      RecentReport
        .includes(report_category: :report_group)
        .within_bounds(@sw_lat, @sw_lng, @ne_lat, @ne_lng)
    end

    def convert_clusters_with_single_report
      @clusters.each do |cluster|
        if cluster[:total] == 1
          @reports << RecentReport.within_radius(cluster[:latitude], cluster[:longitude], 20).take
        end
      end
      @clusters.delete_if { |cluster| cluster[:total] <= 1 }
    end

    def recluster_with_hierachical
      clusterer = Ai4r::Clusterers::MedianLinkage.new
      clusterer.distance_function = lambda do |a,b|
        Ai4r::Data::Proximity.squared_euclidean_distance(
          [a[0], a[1]],
          [b[0], b[1]])
      end

      # Recluster based on minimum view port dimension
      # One dimension is only allowed maximum 4 clusters
      max_d = [(@ne_lat - @sw_lat).abs, (@ne_lng - @sw_lng).abs].min / 4
      max_d = (max_d * max_d) # We used squared_euclidean_distance, so the max_d must be squared
      data_set = Ai4r::Data::DataSet.new(
        data_items: @clusters.map { |c| [c.latitude, c.longitude, c.total] }
      )
      clusterer.build(data_set, distance: max_d)
      @clusters = clusterer.clusters.map do |hc|
        latitude, longitude, total = 0, 0, 0
        hc.data_items.each do |hci|
          latitude += hci[0] * hci[2] # (latitude * total)
          longitude += hci[1] * hci[2] # (longitude * total)
          total += hci[2] # total
        end
        OpenStruct.new(latitude: latitude / total, longitude: longitude / total, total: total)
      end
    end
end
