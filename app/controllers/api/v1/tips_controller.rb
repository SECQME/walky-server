class Api::V1::TipsController < BaseApiController
  before_action :parse_json_request, only: [:create]
  respond_to :json

  def index
    params[:page] ||= 1
    params[:per_page] ||= 5

    if params[:radius]
      unless params[:latitude] and params[:longitude]
        params[:latitude], params[:longitude] = params[:location].split(",", 2)
      end

      @tips = Tip.within_radius(params[:latitude], params[:longitude], params[:radius].to_f * 1000)
    elsif params[:bounds]
      sw_lat, sw_lng, ne_lat, ne_lng = params[:bounds].split(/[,|]/, 4)

      @tips = Tip.within_bounds(sw_lat, sw_lng, ne_lat, ne_lng)
    end

    @tips = @tips.paginate(:page => params[:page], :per_page => params[:per_page]).order(:id => "DESC")

    render json: @tips
  end

  def create
    @tip = Tip.new(tip_params)
    @tip.location = "POINT(#{params['longitude']} #{params['latitude']})"
    @tip.save
    render json: @tip
  end

  def show
    @tip = Tip.find(params[:tip_id])
    render json: @tip
  end

  private
  def tip_params
    ActionController::Parameters.new(@json_request).permit(
      :description,
      :username,
      :user_id,
      :archived,
      :is_time_sensitive,
      :expiry_date
    )
  end
end