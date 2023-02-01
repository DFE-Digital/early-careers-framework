# frozen_string_literal: true

require_relative "./base_endpoint"

module APIs
  class ECFUsersEndpoint < APIs::BaseEndpoint
    def initialize(*_args)
      super EngageAndLearnApiToken.create_with_random_token!
      call_users_endpoint
    end

    def get_user(user_id)
      @current_id = user_id
      select_user
    end

    def has_full_name?(expected_value)
      has_attribute_value? "full_name", expected_value
    end

    def has_email?(expected_value)
      has_attribute_value? "email", expected_value
    end

    def has_user_type?(expected_value)
      has_attribute_value? "user_type", expected_value
    end

    def has_core_induction_programme?(expected_value)
      has_attribute_value? "core_induction_programme", expected_value
    end

    def has_induction_programme_choice?(expected_value)
      has_attribute_value? "induction_programme_choice", expected_value
    end

  private

    def call_users_endpoint
      @current_record = nil
      @current_id = nil
      @response = nil

      url = "/api/v1/ecf-users"
      headers = {
        user_agent: "Engage and Learn",
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

    def select_user
      @current_record = @response.select { |record| record["id"] == @current_id }.first

      if @current_record.nil?
        raise Capybara::ElementNotFound, "Unable to find record for \"#{@current_id}\" within \n===\n#{JSON.pretty_generate @response}\n===\n"
      end
    end

    def has_attribute_value?(attribute_name, expected_value)
      if @current_record.nil?
        raise "No record selected, Must call <APIs::ECFUsersEndpoint::get_user> with a valid \"participant_id\" first"
      end

      value = @current_record.dig("attributes", attribute_name)
      unless value == expected_value
        raise Capybara::ElementNotFound, "Unable to find attribute \"#{attribute_name}\" for \"#{@current_id}\" with value of \"#{expected_value}\" within \n===\n#{JSON.pretty_generate @response}\n===\n"
      end

      true
    end
  end
end
