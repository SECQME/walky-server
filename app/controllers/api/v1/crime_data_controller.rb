class Api::V1::CrimeDataController < BaseApiController
  before_action :parse_json_request, only: [:create]
  respond_to :json

  # GET /crime_data
  # e.g: /crime_data?location=41.878465,-87.6395934&radius=0.5&page=1&per_page=5
  # e.g: /crime_data?bounds=41.835345,-87.623239|41.839009,-87.618085&page=1&per_page=5
  def index
    params[:page] ||= 1
    params[:per_page] ||= 5

    if params[:radius]
      unless params[:latitude] and params[:longitude]
        params[:latitude], params[:longitude] = params[:location].split(",", 2)
      end

      @crime_data = CrimeDatum
        .within_radius(params[:latitude], params[:longitude], params[:radius].to_f * 1000)
    elsif params[:bounds]
      sw_lat, sw_lng, ne_lat, ne_lng = params[:bounds].split(/[,|]/, 4)

      @crime_data = CrimeDatum
        .within_bounds(sw_lat, sw_lng, ne_lat, ne_lng)
    end

    @crime_data = @crime_data.paginate(:page => params[:page], :per_page => params[:per_page]).order(:id => "DESC")

    render json: @crime_data
  end
end
