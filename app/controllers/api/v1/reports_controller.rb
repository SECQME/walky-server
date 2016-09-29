class Api::V1::ReportsController < BaseApiController
  before_action :parse_json_request, only: [:create]
  respond_to :json

  # GET /reports
  # e.g: /reports?latitude=41.878465&longitude=-87.6395934&radius=0.5&page=1&per_page=5
  # e.g: /reports?bounds=41.835345,-87.623239|41.839009,-87.618085&page=1&per_page=5
  def index
    params[:page] ||= 1
    params[:page] = params[:page].to_i
    params[:zoom_level] = params[:zoom_level].to_i

    paginated = true

    allowed_crime_types = Rails.cache.fetch("crime_types_for_reports", expires_in: 10.minutes) do
      other_report_category = ReportCategory.where(name: "Others").take
      CrimeType.where("report_category_id <> ? AND crime_weight > ?", other_report_category.id, 0).pluck(:id)
    end

    if params[:radius]
      unless params[:latitude] and params[:longitude]
        params[:latitude], params[:longitude] = params[:location].split(",", 2)
      end

      @reports = Report
        .includes(report_category: :report_group)
        .where("report_time >= ?", Date.today-3.month)
        .within_radius(params[:latitude], params[:longitude], params[:radius].to_f * 1000)
      @crime_data = CrimeDatum
        .includes(crime_type: {report_category: :report_group})
        .includes(:city)
        .where(crime_type: allowed_crime_types)
        .where("occurred_at >= ?", Date.today-3.month)
        .within_radius(params[:latitude], params[:longitude], params[:radius].to_f * 1000)
    elsif params[:bounds]
      sw_lat, sw_lng, ne_lat, ne_lng = params[:bounds].split(/[,|]/, 4).map { |e| e.to_f  }

      if params[:zoom_level] and params[:zoom_level] < 13
        params[:zoom_level] ||= params[:zoom_level].to_i

        paginated = false

        if params[:per_page]
          params[:per_page] = params[:per_page].to_i
          params[:per_page] = 100 if params[:per_page] > 100
        else
          case params[:zoom_level]
          when 0..10
            params[:per_page] = 9
          else
            params[:per_page] = 36
          end
        end

        # HACK: This will change per_page params because of bug in mobile apps
        case params[:zoom_level]
        when 0..10
          params[:per_page] = 9
        when 10..13
          params[:per_page] = 16
        else
          params[:per_page] = 16
        end

        n = Math.sqrt(params[:per_page]).ceil
        delta_lat = (ne_lat - sw_lat) / n
        delta_lng = (ne_lng - sw_lng) / n

        @reports = []
        @crime_data = []

        for i in 0..n-1
          i_sw_lat = sw_lat + (i * delta_lat)
          i_ne_lat = i_sw_lat + delta_lat

          for j in 0..n-1
            i_sw_lng = sw_lng + (j * delta_lng)
            i_ne_lng = i_sw_lng + delta_lng

            report = Report
              .includes(report_category: :report_group)
              .where("report_time >= ?", Date.today-3.month)
              .within_bounds(i_sw_lat, i_sw_lng, i_ne_lat, i_ne_lng)
              .offset(params[:page] - 1)
              .take

            if report
              logger.warn "XXXXXXXXXXXXXXXXXXXXXXXXXXXXX #{report}"
              @reports << report
            else
              crime_datum = CrimeDatum
                .includes(crime_type: {report_category: :report_group})
                .includes(:city)
                .where(crime_type: allowed_crime_types)
                .where("occurred_at >= ?", Date.today-3.month)
                .within_bounds(i_sw_lat, i_sw_lng, i_ne_lat, i_ne_lng)
                .offset(params[:page] - 1)
                .take

              if crime_datum
                @crime_data << crime_datum
              end
            end
          end
        end
      else
        @reports = Report
          .includes(report_category: :report_group)
          .where("report_time >= ?", Date.today-3.month)
          .within_bounds(sw_lat, sw_lng, ne_lat, ne_lng)
        @crime_data = CrimeDatum
          .includes(crime_type: {report_category: :report_group})
          .includes(:city)
          .where(crime_type: allowed_crime_types)
          .where("occurred_at >= ?", Date.today-3.month)
          .within_bounds(sw_lat, sw_lng, ne_lat, ne_lng)
      end
    end

    if (paginated) then
      params[:per_page] ||= 9

      # HACK: This will change per_page params because of bug in mobile apps
      params[:per_page] = 12

      @reports = @reports.paginate(:page => params[:page], :per_page => params[:per_page]).order(:id => "DESC")
      @crime_data = @crime_data.paginate(:page => params[:page], :per_page => params[:per_page]).order(:id => "DESC")
      @crime_data = @crime_data.all
    end

    @reports = @reports + convert_to_report(@crime_data)

    # HACK: This will return empty page for page other than 1 due bug in mobile apps
    unless params[:page] == 1
      @reports = []
    end

    respond_with @reports
  end

  # POST /reports
  def create
    @report = Report.new(report_params)
    @report.location = "POINT(#{report_params['longitude']} #{report_params['latitude']})"
    @report.user = current_user
    @report.save
    respond_with @report
  end

  def heartbeat
    @report = Report.first
    render json: { "ping" => "pong" }
  end

	def env
    render json: { env: Rails.env }
	end

  private
    def report_params
      ActionController::Parameters.new(@json_request).permit(
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

    def convert_to_report crime_data
      crime_data.map do |crime_datum|
        Report.new(
          description: crime_datum.note,
          report_time: crime_datum.occurred_at,
          report_category: crime_datum.crime_type.report_category,
          latitude: crime_datum.location.y,
          longitude: crime_datum.location.x,
          street_name: crime_datum.address,
          city: crime_datum.city.name,
          state: crime_datum.city.state,
          country: crime_datum.city.country,
          postcode: crime_datum.postcode,
          location: crime_datum.location,
          invisible: false,
          user: User.new(
            name: "Walky",
            display_name: "walky"
          )
        )
      end
    end
end
