class Api::V1::UsersController < BaseApiController
  before_action :authenticate_with_token!, only: [:show_me, :update_me]
  respond_to :json

  def show_me
    @size = params[:size]? params[:size] : 100.to_s
    @current_user = current_user
    @external_auth = ExternalAuth.where(user_id: current_user.id).first
    render @current_user
  end

  def update_me
    current_user.update_attributes(user_params)
    render json: current_user
  end

  private
    def user_params
      ActionController::Parameters.new(json_params).permit(
        :name,
        :display_name
      )
    end
end
