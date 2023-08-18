# frozen_string_literal: true

require_relative "./base_endpoint"

module APIs
  class NPQApplicationsEndpoint < APIs::BaseEndpoint
    def initialize(args)
      super args
      call_applications_endpoint
    end

    def get_application(application_id)
      @current_id = application_id
      select_application
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

    def has_school_ukprn?(expected_value)
      has_attribute_value? "school_ukprn", expected_value
    end

    def has_school_urn?(expected_value)
      has_attribute_value? "school_urn", expected_value
    end

    def has_status?(expected_value)
      has_attribute_value? "status", expected_value
    end

    def has_cohort?(expected_value)
      has_attribute_value? "cohort", expected_value.to_s
    end

    def has_participant_id?(expected_value)
      has_attribute_value? "participant_id", expected_value
    end

    def has_course_identifier?(expected_value)
      has_attribute_value? "course_identifier", expected_value
    end

    def eligible_for_funding?
      has_attribute_value? "eligible_for_funding", true
    end

    def working_in_a_school?
      has_attribute_value? "works_in_school", true
    end

  private

    def url = "/api/v1/npq-applications"

    def call_applications_endpoint
      @current_record = nil
      @current_id = nil
      @response = nil

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

    def select_application
      @current_record = @response.select { |record| record["id"] == @current_id }.first

      if @current_record.nil?
        raise Capybara::ElementNotFound, "Unable to find record for \"#{@current_id}\" within \n===\n#{JSON.pretty_generate @response}\n===\n"
      end
    end

    def has_attribute_value?(attribute_name, expected_value)
      if @current_record.nil?
        raise "No record selected, Must call <APIs::NPQApplicationsEndpoint::get_application> with a valid \"application_id\" first"
      end

      value = @current_record.dig("attributes", attribute_name)
      unless value == expected_value
        raise Capybara::ElementNotFound, "Unable to find attribute \"#{attribute_name}\" for \"#{@current_id}\" with value of \"#{expected_value}\" within \n===\n#{JSON.pretty_generate @response}\n===\n"
      end

      true
    end
  end
end
