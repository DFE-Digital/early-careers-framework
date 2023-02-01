# frozen_string_literal: true

require_relative "./base_endpoint"

module APIs
  class ParticipantDeferEndpoint < APIs::BaseEndpoint
    def post_defer_notice(participant_id, course_identifier, reason_code)
      @current_id = participant_id
      post_request course_identifier, reason_code
    end

    def responded_with_full_name?(expected_value)
      has_attribute_value? "full_name", expected_value
    end

    def responded_with_email?(expected_value)
      has_attribute_value? "email", expected_value
    end

    def responded_with_status?(expected_value)
      has_attribute_value? "status", expected_value
    end

    def responded_with_training_status?(expected_value)
      has_attribute_value? "training_status", expected_value
    end

  private

    def post_request(course_identifier, reason_code)
      @response = nil

      url = "/api/v1/participants/#{@current_id}/defer"
      attributes = {
        reason: reason_code,
        course_identifier:,
      }
      params = build_params attributes
      headers = {
        "Authorization": "Bearer #{@token}",
        "Content-type": "application/json",
      }
      session = ActionDispatch::Integration::Session.new(Rails.application)
      session.put(url, headers:, params:)

      @response = JSON.parse(session.response.body)["data"]
      if @response.nil?
        error = JSON.parse(session.response.body)
        raise "POST request at #{Time.zone.now} to <#{url}> with request body \n#{JSON.pretty_generate attributes}\n failed due to \n===\n#{error}\n===\n"
      end
    end

    def build_params(attributes)
      {
        data: {
          type: "participant-defer",
          attributes:,
        },
      }.to_json
    end

    def has_attribute_value?(attribute_name, expected_value)
      if @response.nil?
        raise "No response found, Must call <APIs::ParticipantDeferEndpoint::post_defer_notice> with a valid \"participant_id\" and \"reason_code\" first"
      end

      value = @response.dig("attributes", attribute_name)
      unless value == expected_value
        raise Capybara::ElementNotFound, "Unable to find attribute \"#{attribute_name}\" for \"#{@current_id}\" with value of \"#{expected_value}\" within \n===\n#{JSON.pretty_generate @response}\n===\n"
      end

      true
    end
  end
end
