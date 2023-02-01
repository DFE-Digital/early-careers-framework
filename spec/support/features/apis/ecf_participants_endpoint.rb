# frozen_string_literal: true

require_relative "./base_endpoint"

module APIs
  class ECFParticipantsEndpoint < APIs::BaseEndpoint
    def initialize(args)
      super args
      call_participants_endpoint
    end

    def get_participant(participant_id)
      @current_id = participant_id
      select_participant
    end

    def has_full_name?(expected_value)
      has_attribute_value? "full_name", expected_value
    end

    def has_email_address?(expected_value)
      has_attribute_value? "email", expected_value
    end

    def has_trn?(expected_value)
      has_attribute_value? "teacher_reference_number", expected_value
    end

    def has_school_urn?(expected_value)
      has_attribute_value? "school_urn", expected_value
    end

    def has_participant_type?(expected_value)
      has_attribute_value? "participant_type", expected_value
    end

    def has_status?(expected_value)
      has_attribute_value? "status", expected_value
    end

    def has_training_status?(expected_value)
      has_attribute_value? "training_status", expected_value
    end

  private

    def call_participants_endpoint
      @current_record = nil
      @current_id = nil
      @response = nil

      url = "/api/v1/participants/ecf"
      headers = {
        "Authorization": "Bearer #{@token}",
        "Content-type": "application/json",
      }
      session = ActionDispatch::Integration::Session.new Rails.application
      session.get(url, headers:)

      @response = JSON.parse(session.response.body)["data"]
      if @response.nil?
        error = JSON.parse(session.response.body)
        raise "GET request at #{Time.zone.now} to <#{url}> failed due to \n===\n#{error}\n===\n"
      end
    end

    def select_participant
      @current_record = @response.select { |record| record["id"] == @current_id }.first

      if @current_record.nil?
        raise Capybara::ElementNotFound, "Unable to find record for \"#{@current_id}\" within \n===\n#{JSON.pretty_generate @response}\n===\n"
      end
    end

    def has_attribute_value?(attribute_name, expected_value)
      if @current_record.nil?
        raise "No record selected, Must call <APIs::ECFParticipantsEndpoint::get_participant> with a valid \"participant_id\" first"
      end

      value = @current_record.dig("attributes", attribute_name)
      unless value == expected_value
        raise Capybara::ElementNotFound, "Unable to find attribute \"#{attribute_name}\" for \"#{@current_id}\" with value of \"#{expected_value}\" within \n===\n#{JSON.pretty_generate @response}\n===\n"
      end

      true
    end
  end
end
