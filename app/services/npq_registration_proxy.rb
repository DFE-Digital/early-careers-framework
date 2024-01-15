# frozen_string_literal: true

require "net/http"

class NPQRegistrationProxy
  attr_reader :request,
              :authorization,
              :path,
              :params,
              :method,
              :request_body

  def initialize(request)
    @request = request
    @authorization = request.authorization
    @path = request.path
    @params = request.query_parameters
    @method = request.method
    @request_body = request.body
  end

  def perform
    case method
    when "GET"
      get
    when "POST"
      post(request_body)
    when "PUT"
      put(request_body)
    end
  end

  def get
    Net::HTTP.start(uri.hostname, uri.port) do |http|
      request = Net::HTTP::Get.new(uri)
      request["Authorization"] = authorization

      http.request(request)
    end
  end

  def put(request_body)
    Net::HTTP.start(uri.hostname, uri.port) do |http|
      request = Net::HTTP::Put.new(uri)
      request["Authorization"] = authorization

      http.request(request, request_body)
    end
  end

  def post(request_body)
    Net::HTTP.start(uri.hostname, uri.port) do |http|
      request = Net::HTTP::Post.new(uri)
      request["Authorization"] = authorization

      http.request(request, request_body)
    end
  end

private

  def uri
    @uri ||=
      begin
        uri = URI("#{Rails.configuration.npq_registration_api_url}#{path}")
        uri.query = URI.encode_www_form(params) if params.present?
        uri
      end
  end
end
