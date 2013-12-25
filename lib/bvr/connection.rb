require 'faraday'
require 'rack'

module Bvr
  class Connection
    BASE_URI = 'https://www.voipinfocenter.com/API/Request.ashx'

    def self.base_uri
      BASE_URI
    end

    def self.connection(faraday_adapter=Faraday.default_adapter)
      Faraday.new(url: self.base_uri) do |faraday|
        faraday.response :logger
        faraday.adapter faraday_adapter
      end
    end

    def self.query(queryH)
      params = {
        username: Bvr.config.username,
        password: Bvr.config.password
      }
      queryH.merge! params
      ::Rack::Utils.build_query queryH
    end
  end
end
