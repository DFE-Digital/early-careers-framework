# frozen_string_literal: true

module APIs
  class PostParticipantDeclarationsEndpoint
    include Capybara::DSL
    include RSpec::Matchers

    attr_reader :response

    def initialize(token)
      @token = token
    end

    def post_training_declaration(participant_id, course_identifier, declaration_type, declaration_date)
      @current_id = participant_id
      post_declaration course_identifier, declaration_type, declaration_date
    end

    def has_declaration_type?(expected_value)
      has_attribute_value? "declaration_type", expected_value.to_s.gsub("_", "-")
    end

    def has_eligible_for_payment?(expected_value)
      has_attribute_value? "eligible_for_payment", expected_value
    end

    def has_voided?(expected_value)
      has_attribute_value? "voided", expected_value
    end

    def has_state?(expected_value)
      has_attribute_value? "state", expected_value
    end

  private

    def post_declaration(course_identifier, declaration_type, declaration_date, evidence_held: true)
      @response = nil

      url = "/api/v1/participant-declarations"
      @attributes = {
        participant_id: @current_id,
        declaration_type: declaration_type.to_s.gsub("_", "-"),
        declaration_date: declaration_date.rfc3339,
        course_identifier: course_identifier,
        evidence_held: evidence_held ? "self-study-material-completed" : nil,
      }
      params = build_params(@attributes)
      headers = {
        "Authorization": "Bearer #{@token}",
        "Content-type": "application/json",
      }
      session = ActionDispatch::Integration::Session.new(Rails.application)
      session.post url, headers: headers, params: params

      @response = JSON.parse(session.response.body)["data"]
      if @response.nil?
        error = JSON.pretty_generate JSON.parse(session.response.body)["errors"]
        raise "POST request to <#{url}> with request body \n#{JSON.pretty_generate @attributes}\n failed due to \n===\n#{error}\n===\n"
      end
    end

    def build_params(attributes)
      {
        data: {
          type: "participant-declaration",
          attributes: attributes,
        },
      }.to_json
    end

    def has_attribute_value?(attribute_name, expected_value)
      if @response.nil?
        raise "No response found, Must call <APIs::PostParticipantDeclarationsEndpoint::post_training_declaration> with a valid \"participant_id\", \"declaration_date\" and \"declaration_type\" first"
      end

      value = @response.dig("attributes", attribute_name)
      unless value == expected_value
        raise Capybara::ElementNotFound, "Unable to find attribute \"#{attribute_name}\" for \"#{@current_id}\" with value of \"#{expected_value}\" within \n===\n#{JSON.pretty_generate @response}\n===\n"
      end

      true
    end
  end
end
