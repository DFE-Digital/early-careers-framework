# frozen_string_literal: true

module APIs
  class ECFUsersEndpoint
    include Capybara::DSL
    include RSpec::Matchers

    def initialize
      @token = EngageAndLearnApiToken.create_with_random_token!
      @session = ActionDispatch::Integration::Session.new(Rails.application)
    end

    def user_is_fip_ect?(participant)
      user = get_user participant.user
      if !user.nil?
        attributes = user["attributes"]

        attributes["email"] == participant.user.email.to_s &&
          attributes["full_name"] == participant.user.full_name.to_s &&
          attributes["user_type"] == "early_career_teacher" &&
          attributes["core_induction_programme"] == "none" &&
          attributes["induction_programme_choice"] == "full_induction_programme"
      else
        false
      end
    end

    def user_is_cip_ect?(participant)
      user = get_user participant.user
      if !user.nil?
        attributes = user["attributes"]

        attributes["email"] == participant.user.email.to_s &&
          attributes["full_name"] == participant.user.full_name.to_s &&
          attributes["user_type"] == "early_career_teacher" &&
          attributes["core_induction_programme"] == "none" &&
          attributes["induction_programme_choice"] == "core_induction_programme"
      else
        false
      end
    end

  private

    def get_users
      @session.get("/api/v1/ecf-users",
                   headers: {
                     user_agent: "Engage and Learn",
                     "Authorization": "Bearer #{@token}",
                   })

      JSON.parse(@session.response.body)["data"]
    end

    def get_user(user)
      get_users.select { |record| record["id"] == user.id }.first
    end
  end
end
