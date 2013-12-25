require 'faraday'
require 'rack'

module Bvr
  class Connection
    BASE_URI = 'https://www.voipinfocenter.com'
    API_PATH = '/API/Request.ashx?'

    def self.base_uri
      BASE_URI
    end

    def self.connection(faraday_adapter=Faraday.default_adapter)
      Faraday.new(url: self.base_uri) do |faraday|
        faraday.response :logger
        faraday.adapter faraday_adapter
      end
    end

    def self.get(params)
      #TODO: prase body for 500
      self.connection.get(self.uri(params)).body
    end

    def self.uri(queryH)
      params = {
        username: Bvr.config.username,
        password: Bvr.config.password
      }
      queryH.merge! params
      "#{API_PATH}#{::Rack::Utils.build_query queryH}"
    end
  end
end
