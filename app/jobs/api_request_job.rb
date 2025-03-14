# frozen_string_literal: true

class ApiRequestJob
  include Sidekiq::Worker
  include ActionController::HttpAuthentication::Token

  def perform(request_data, response_data, status_code, created_at, uuid)
    request_data = request_data.with_indifferent_access
    response_data = response_data.with_indifferent_access
    request_headers = request_data.fetch(:headers, {})
    token = auth_token(request_headers.delete("HTTP_AUTHORIZATION"))
    cpd_lead_provider = token.is_a?(LeadProviderApiToken) ? token.owner : nil

    response_headers = response_data[:headers]
    response_body = response_data[:body]

    data = {
      request_path: request_data[:path],
      request_headers:,
      request_body: request_body(request_data),
      request_method: request_data[:method],
      response_headers:,
      response_body: response_hash(response_body, status_code),
      status_code:,
      user_description: token&.owner_description,
      cpd_lead_provider:,
      created_at:,
    }

    ApiRequest.create!(data)
    send_analytics_event(cpd_lead_provider:, data:, uuid:)
  end

private

  AuthorizationStruct = Struct.new(:authorization)

  def auth_token(auth_header)
    return if auth_header.blank?

    token, _options = token_and_options(AuthorizationStruct.new(auth_header))
    ApiToken.find_by_unhashed_token(token)
  end

  def response_hash(response_body, status)
    return {} unless status > 299
    return {} unless response_body

    JSON.parse(response_body)
  rescue JSON::ParserError
    { body: "#{status} did not respond with JSON" }
  end

  def request_body(request_data)
    if request_data[:body].present?
      JSON.parse(request_data[:body])
    else
      request_data[:params]
    end
  rescue JSON::ParserError
    { error: "request data did not contain valid JSON" }
  end

  def send_analytics_event(cpd_lead_provider:, data:, uuid:)
    return if cpd_lead_provider.blank?

    event = DfE::Analytics::Event.new
                                 .with_type(:persist_api_request)
                                 .with_request_uuid(uuid)
                                 .with_entity_table_name(:api_requests)
                                 .with_data(data:)
                                 .with_user(cpd_lead_provider)

    DfE::Analytics::SendEvents.do(Array.wrap(event.as_json))
  end
end
