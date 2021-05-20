# frozen_string_literal: true

module Dqt
  class Client
    def initialize(
      headers: Dqt.configuration.client.headers,
      host: Dqt.configuration.client.host,
      params: Dqt.configuration.client.params
    )
      self.headers = headers
      self.host = host
      self.params = params
    end

    def api
      @api ||= Api.new(client: self)
    end

    def get(path: "/", params: {})
      http_client = HTTPClient.new

      headers = {
        'Content-Type': "application/json",
      }.merge(send(:headers))

      params = params.merge(send(:params))

      response = Response.new(
        response: http_client.get(
          url(path),
          header: headers,
          query: params,
        ),
      )
      raise ResponseError, response if [*0..199, *300..599].include? response.code

      response.body
    end

  private

    attr_accessor :headers, :host, :params

    def url(path)
      "#{host}#{path}"
    end
  end
end
