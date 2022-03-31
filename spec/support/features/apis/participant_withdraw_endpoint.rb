# frozen_string_literal: true

module APIs
  class ParticipantWithdrawEndpoint
    include Capybara::DSL
    include RSpec::Matchers

    attr_reader :response

    def initialize(token)
      @token = token
    end

    def post_withdraw_notice(participant_id, course_identifier, reason_code)
      @current_id = participant_id
      post_request course_identifier, reason_code
    end

    def responded_with_full_name?(expected_value)
      has_attribute_value? "full_name", expected_value
    end

    def responded_with_email?(expected_value)
      has_attribute_value? "email", expected_value
    end

    def responded_with_obfuscated_email?
      has_attribute_value? "email", nil
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

      url = "/api/v1/participants/#{@current_id}/withdraw"
      params = build_params reason: reason_code, course_identifier: course_identifier
      headers = {
        "Authorization": "Bearer #{@token}",
        "Content-type": "application/json",
      }
      session = ActionDispatch::Integration::Session.new(Rails.application)
      session.put url, headers: headers, params: params

      @response = JSON.parse(session.response.body)["data"]
      if @response.nil?
        error = JSON.parse(session.response.body)
        raise "PUT request to <#{url}> failed due to \n===\n#{error}\n===\n"
      end
    end

    def build_params(attributes)
      {
        data: {
          type: "participant-withdraw",
          attributes: attributes,
        },
      }.to_json
    end

    def has_attribute_value?(attribute_name, expected_value)
      if @response.nil?
        raise "No response found, Must call <APIs::ParticipantWithdrawEndpoint::post_withdraw_notice> with a valid \"participant_id\" and \"reason_code\" first"
      end

      value = @response.dig("attributes", attribute_name)
      unless value == expected_value
        raise Capybara::ElementNotFound, "Unable to find attribute \"#{attribute_name}\" for \"#{@current_id}\" with value of \"#{expected_value}\" within \n===\n#{JSON.pretty_generate @response}\n===\n"
      end

      true
    end
  end
end
