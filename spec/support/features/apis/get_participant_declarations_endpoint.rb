# frozen_string_literal: true

require_relative "./base_endpoint"

module APIs
  class GetParticipantDeclarationsEndpoint < APIs::BaseEndpoint
    def get_training_declarations(participant_id)
      @current_id = participant_id
      get_declarations
    end

    def has_declarations?(declaration_types = [])
      found = list_declarations
      expectation = declaration_types.map { |dt| dt.to_s.gsub("_", "-") }

      if found.sort == expectation.sort
        true
      else
        raise RSpec::Expectations::ExpectationNotMetError, "expected the returned declarations of #{found} to equal #{expectation}"
      end
    end

    def has_ordered_declarations?(declaration_types = [])
      found = list_declarations
      expectation = declaration_types.map { |dt| dt.to_s.gsub("_", "-") }

      if found == expectation
        true
      else
        raise RSpec::Expectations::ExpectationNotMetError, "expected the returned declarations of #{found} to equal #{expectation}"
      end
    end

    def get_declaration(declaration_type)
      @current_type = declaration_type.to_s.gsub("_", "-")
      select_declaration
    end

  private

    def get_declarations
      @current_record = nil
      @response = nil

      url = "/api/v1/participant-declarations"
      attributes = {
        participant_id: @current_id,
      }
      params = build_filter_params attributes
      headers = {
        "Authorization": "Bearer #{@token}",
        "Content-type": "application/json",
      }
      session = ActionDispatch::Integration::Session.new(Rails.application)
      session.get(url, headers:, params:)

      @response = JSON.parse(session.response.body)["data"]
      if @response.nil?
        error = JSON.parse(session.response.body)
        raise "GET request at #{Time.zone.now} to <#{url}> with request params \n#{JSON.pretty_generate attributes}\n failed due to \n===\n#{error}\n===\n"
      end
    end

    def select_declaration
      @current_record = @response.select { |record| record.dig("attributes", "declaration_type") == @current_type.to_s }.first

      if @current_record.nil?
        raise Capybara::ElementNotFound, "Unable to find record for \"#{@current_type}\" within \n===\n#{JSON.pretty_generate @response}\n===\n"
      end
    end

    def list_declarations
      @response.map { |record| record.dig("attributes", "declaration_type") }
    end

    def build_filter_params(filter)
      {
        filter:,
      }.to_json
    end

    def has_attribute_value?(attribute_name, expected_value)
      if @response.nil?
        raise "No response found, Must call <APIs::GetParticipantDeclarationsEndpoint::get_training_declarations> with a valid \"participant_id\" first"
      end

      value = @response.dig("attributes", attribute_name)
      unless value == expected_value
        raise Capybara::ElementNotFound, "Unable to find attribute \"#{attribute_name}\" for \"#{@current_id}\" with value of \"#{expected_value}\" within \n===\n#{JSON.pretty_generate @response}\n===\n"
      end

      true
    end
  end
end
