# frozen_string_literal: true

module APIs
  class ECFParticipantsEndpoint
    include Capybara::DSL
    include RSpec::Matchers

    def initialize(token)
      @token = token
      @session = ActionDispatch::Integration::Session.new(Rails.application)
    end

    def check_can_access_participant_details(participant)
      expect(get_participant_ids).to include(participant.user.id)

      self
    end

    def check_cannot_access_participant_details(participant)
      expect(get_participant_ids).to_not include(participant.user.id)

      self
    end

  private

    def get_participants
      @session.get("/api/v1/participants/ecf",
                   headers: { "Authorization": "Bearer #{@token}" })

      JSON.parse(@session.response.body)["data"]
    end

    def get_participant_ids
      get_participants.map do |record|
        record["id"]
      end
    end
  end
end
