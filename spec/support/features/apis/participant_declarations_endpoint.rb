# frozen_string_literal: true

module APIs
  class ParticipantDeclarationsEndpoint
    include Capybara::DSL
    include RSpec::Matchers

    def initialize(token)
      @token = token
      @session = ActionDispatch::Integration::Session.new(Rails.application)
    end

    def post_started_declaration(participant)
      post_declaration participant,
                       "started",
                       participant.schedule.milestones.first.start_date + 2.days
    end

    def can_access_participant_declarations?(participant)
      declarations = get_declarations participant

      !declarations.empty?
    end

  private

    def get_declarations(participant)
      @session.get("/api/v1/participant-declarations",
                   headers: { "Authorization": "Bearer #{@token}" },
                   params: { filter: { participant_id: participant.user.id } })

      JSON.parse(@session.response.body)["data"] || []
    end

    def post_declaration(participant, declaration_type, declaration_date)
      params = build_params({
        participant_id: participant.user.id,
        declaration_type: declaration_type,
        declaration_date: declaration_date.rfc3339,
        course_identifier: "ecf-induction",
      })

      @session.post("/api/v1/participant-declarations",
                    headers: {
                      "Authorization": "Bearer #{@token}",
                      "Content-type": "application/json",
                    },
                    params: params)

      JSON.parse(@session.response.body)["data"]
    end

    def build_params(attributes)
      {
        data: {
          type: "participant-declaration",
          attributes: attributes,
        },
      }.to_json
    end
  end
end
