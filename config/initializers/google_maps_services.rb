GoogleMapsService.configure do |config|
  config.key = ''
  config.queries_per_second = 10
end

class GoogleMapsService::Client
  include Singleton
end
