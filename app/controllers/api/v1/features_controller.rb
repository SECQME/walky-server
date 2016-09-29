class Api::V1::FeaturesController < BaseApiController
  respond_to :json

  def index
    @features = Feature.all
    respond_with @features
  end

  def vote
    @feature = Feature.find(params[:id])
    @feature.total_votes += 1
    @feature.save
    render json: @feature
  end

  private
  def feature_params
    ActionController::Parameters.new(@json_request).permit(
      :name,
      :description
    )
  end
end
