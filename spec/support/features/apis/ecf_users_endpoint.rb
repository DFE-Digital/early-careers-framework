# frozen_string_literal: true

module APIs
  class ECFUsersEndpoint
    include Capybara::DSL
    include RSpec::Matchers

    def initialize
      @token = EngageAndLearnApiToken.create_with_random_token!
      @session = ActionDispatch::Integration::Session.new(Rails.application)
    end

    def check_user_is_fip_ect(participant)
      user = get_user participant.user
      expect(user).to_not be_nil

      attributes = user["attributes"]
      expect(attributes["email"]).to eq participant.user.email
      expect(attributes["full_name"]).to eq participant.user.full_name
      expect(attributes["user_type"]).to eq "early_career_teacher"
      expect(attributes["core_induction_programme"]).to eq "none"
      expect(attributes["induction_programme_choice"]).to eq "full_induction_programme"

      self
    end

    def check_user_is_cip_ect(participant)
      user = get_user participant.user
      expect(user).to_not be_nil

      attributes = user["attributes"]
      expect(attributes["email"]).to eq participant.user.email
      expect(attributes["full_name"]).to eq participant.user.full_name
      expect(attributes["user_type"]).to eq "early_career_teacher"
      expect(attributes["core_induction_programme"]).to eq "none"
      expect(attributes["induction_programme_choice"]).to eq "core_induction_programme"

      self
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
