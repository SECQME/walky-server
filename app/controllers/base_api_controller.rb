class BaseApiController < ApplicationController
  protect_from_forgery with: :null_session
  include Authenticable

  private
    def parse_json_request
      @json_request = JSON.parse(request.body.read)
    end

    def json_params
      @json_params ||= JSON.parse(request.body.read, symbolize_names: true)
    end
end
