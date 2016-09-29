class Api::V1::SessionsController < BaseApiController
  respond_to :json

  def external
    ts = Time.now
    auth_token = json_params[:auth_token]
    case params[:provider]
    when "facebook"
      auth = auth_via_facebook(auth_token)
    when "wom"
      auth = auth_via_wom(auth_token)
    else
      respond_with status: 404
    end

    if auth
      api_key = ApiKey.create!(user: auth.user)
      status = (auth.user.created_at > ts) ? "new_user" : "existing_user"

      render json: {access_token: api_key.access_token, status: status}
    end
  end

  private
    def auth_via_facebook(auth_token)
      graph = Koala::Facebook::API.new(auth_token)
      fb_user = graph.get_object("me?fields=id,name,email")
      auth = ExternalAuth.where(provider: "facebook", uid: fb_user["id"]).first
      unless auth
        if fb_user["email"]
          user = create_user(fb_user["name"], fb_user["email"])
          auth = ExternalAuth.create!(user: user, provider: "facebook", uid: fb_user["id"])
        else
          render json: {error_description: "email_missing"}, status: :unprocessable_entity
        end
      end
      auth
    end

    def auth_via_wom(auth_token)
      wom_response = HTTParty.put("https://secq.me/mainportal/rs/v2.1/users/me",
  			:body => "{}",
  			:headers => {"Authorization" => "Bearer #{auth_token}", "Content-Type" => "application/json"})
  		wom_user = JSON.parse(wom_response.body)
      auth = ExternalAuth.where(provider: "wom", uid: wom_user["id"]).first
      unless auth
        user = create_user(wom_user["name"], wom_user["emailAddr"])
        auth = ExternalAuth.create!(user: user, provider: "wom", uid: wom_user["id"])
      end
      auth
    end

    def create_user(name, email)
      random_password = SecureRandom.hex
      User.create!(
        name: name,
        display_name: name,
        email: email,
        password: random_password,
        password_confirmation: random_password
      )
    end
end
