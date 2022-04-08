require 'terminal-table'

require 'ecf_api_client/participant'
class ECFApiClient
  class << self
    def run
      eligible, ineligible = Participant.participants.partition(&:eligible_for_funding)
      Participant.display eligible
      Participant.display ineligible
      participant = eligible.first
      participant.record_start_declaration
    end
  end

  def post_started_declaration(participant)
    params = {
      type: "participant-declaration",
      attributes: {
        participant_id: participant["id"],
        declaration_type: "started",
        declaration_date: Date.new(2021, 9, 2).rfc3339,
        course_identifier: participant.dig("attributes", "participant_type") == "mentor" ? "ecf-mentor" : "ecf-induction",
      },
    }

    conn.post(POST_DECLARATION_ENDPOINT, { data: params }.to_json)
  end
end
