require 'httparty'
class ApiService

	def post_api(url,body)
		response = HTTParty.post(url,
			:body => body.to_json,
			:header => {'ContentType'=> 'application/json'})
		json = JSON.parse(response.body)

	end
end