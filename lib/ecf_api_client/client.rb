require "faraday"
require "faraday/net_http"
require "connection_pool"
class ECFApiClient
  class Client
    API_ENDPOINT = "http://localhost:3000/"

    def pool
      @pool ||= ConnectionPool.new(size: 5) do
        Faraday.new(url: API_ENDPOINT, headers: { "Content-Type" => "application/json" } ) do |f|
          f.request :authorization, "Bearer", "ambition-token"
          f.request :json
          f.response :json
        end
      end
    end
  end
end
