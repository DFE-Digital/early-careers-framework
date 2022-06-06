# frozen_string_literal: true

module APIs
  class GetParticipantDeclarationsEndpoint
    include Capybara::DSL
    include RSpec::Matchers

    attr_reader :response

    def initialize(token)
      @token = token
    end

    def get_training_declarations(participant_id)
      @current_id = participant_id
      get_declarations
    end

    def get_declaration(declaration_type)
      @current_type = declaration_type.to_s.gsub("_", "-")
      select_declaration
    end

    def has_declarations?(declaration_types)
      list_declarations == declaration_types.map { |dt| dt.to_s.gsub("_", "-") }
    end

  private

    def get_declarations
      @current_record = nil
      @response = nil

      url = "/api/v1/participant-declarations"
      params = build_filter_params participant_id: @current_id
      headers = {
        "Authorization": "Bearer #{@token}",
        "Content-type": "application/json",
      }
      session = ActionDispatch::Integration::Session.new(Rails.application)
      session.get url, headers: headers, params: params

      @response = JSON.parse(session.response.body)["data"]
      if @response.nil?
        error = JSON.parse(session.response.body)
        raise "GET request to <#{url}> failed due to \n===\n#{error}\n===\n"
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
