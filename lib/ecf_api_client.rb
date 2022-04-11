# frozen_string_literal: true

require "terminal-table"
require "ecf_api_client/participant"

class ECFApiClient
  class << self
    def run
      eligible, ineligible = Participant.participants.partition(&:eligible_for_funding)
      Participant.display eligible
      Participant.display ineligible
      eligible.map(&:record_start_declaration)
    end
  end
end
