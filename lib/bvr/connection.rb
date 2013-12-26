require 'faraday'
require 'rack'

module Bvr
  class Connection
    BASE_URI = 'https://www.voipinfocenter.com'
    API_PATH = '/API/Request.ashx?'

    attr_accessor :faraday_connection

    def initialize(faraday_adapter=Faraday.default_adapter)
      @faraday_connection = Faraday.new(url: self.base_uri) do |faraday|
        faraday.response :logger
        faraday.adapter faraday_adapter
      end
    end

    def base_uri
      BASE_URI
    end

    def get(params)
      #TODO: prase body for 500
      self.faraday_connection.get(uri(params)).body
    end

    def uri(queryH)
      params = {
        username: Bvr.config.username,
        password: Bvr.config.password
      }
      queryH.merge! params
      "#{API_PATH}#{::Rack::Utils.build_query queryH}"
    end
  end
end
