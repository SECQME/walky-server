# encoding: UTF-8
require 'cgi'
require 'net/http'
require 'open-uri'
require 'json'

class GoogleDirectionsApi
  attr_reader :json, :doc, :status

  @@base_url = 'http://maps.googleapis.com/maps/api/directions/json'

  @@default_options = {
    :language => :en,
    :alternatives => :true,
    :sensor => :false,
    :mode => :walking,
  }

  def initialize(origin, destination, opts=@@default_options)
    @origin = origin
    @destination = destination
    @options = opts.merge({:origin => @origin, :destination => @destination})

    @url = @@base_url + '?' + @options.to_query

    puts @url

    @json = ActiveSupport::JSON.decode(open(@url).read)

    if @json['status'] == 'OK'
      @json['routes'].each do |route|
        route['overview_polyline']['decoded_points'] = decode_polyline(route['overview_polyline']['points'])
        route['legs'].each do |leg|
          leg['steps'].each do |step|
            step['polyline']['decoded_points'] = decode_polyline(step['polyline']['points'])
          end
        end
      end
    end

    mappings = {"lat" => "latitude", "lng" => "longitude"}
    @json = @json.rename_keys(mappings)

    @doc = RecursiveOpenStruct.new(@json, :recurse_over_arrays => true)
    @status = @doc.status
  end

  private
    def decode_polyline(encoded_polyline)
      decoded_points = []
      Polylines::Decoder.decode_polyline(encoded_polyline).each do |location|
        decoded_points << {
          :latitude => location[0],
          :longitude => location[1],
        }
      end
      decoded_points
    end
end

class Hash
  def to_query
    collect do |k, v|
      "#{k}=#{CGI::escape(v.to_s)}"
    end * '&'
  end unless method_defined? :to_query

  def rename_keys(mapping)
    result = {}
    self.map do |k,v|
      mapped_key = mapping[k] ? mapping[k] : k
      result[mapped_key] = v.kind_of?(Hash) ? v.rename_keys(mapping) : v
      result[mapped_key] = v.collect{ |obj| obj.rename_keys(mapping) if obj.kind_of?(Hash)} if v.kind_of?(Array)
    end
    result
  end
end