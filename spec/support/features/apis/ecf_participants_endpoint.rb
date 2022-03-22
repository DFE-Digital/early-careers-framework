# frozen_string_literal: true

module APIs
  class ECFParticipantsEndpoint
    include Capybara::DSL
    include RSpec::Matchers

    def initialize(token)
      @token = token
      @session = ActionDispatch::Integration::Session.new(Rails.application)
    end

    def get_participant_details(participant)
      record = get_participant participant
      record.fetch("attributes", {})
    end

    def participant_has_status?(participant, status)
      record = get_participant participant
      record.fetch("attributes", "status") == status
    end

    def participant_has_training_status?(participant, training_status)
      record = get_participant participant
      record.fetch("attributes", "training_status") == training_status
    end

  private

    def get_participants
      @session.get("/api/v1/participants/ecf",
                   headers: { "Authorization": "Bearer #{@token}" })

      JSON.parse(@session.response.body)["data"]
    end

    def get_participant(participant)
      get_participants.select { |record| record["id"] == participant.user.id }.first || {}
    end
  end
end
