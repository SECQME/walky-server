class Api::V1::CitiesController < BaseApiController
  respond_to :json

	def index
		@cities = Rails.cache.fetch("City.order('name ASC').as_json", expires_in: 10.minutes) { City.order("name ASC").as_json }
    render json: @cities
	end

end
