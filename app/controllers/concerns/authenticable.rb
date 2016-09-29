module Authenticable

  def current_user
    return current_api_key.user if current_api_key
    nil
  end

  def current_api_key
    @current_api_key ||= ApiKey.find_by(access_token: access_token)
  end

  def authenticate_with_token!
    render json: { status: 401, error: "Not authenticated" }, status: :unauthorized unless current_api_key
  end

  private
    def access_token
      pattern = /^Bearer /
      header  = request.headers["Authorization"]
      header.gsub(pattern, '') if header && header.match(pattern)
    end
end
