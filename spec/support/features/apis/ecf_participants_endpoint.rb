# frozen_string_literal: true

require_relative "./participants_endpoint"

module APIs
  class ECFParticipantsEndpoint < ParticipantsEndpoint
  private

    def url = "/api/v1/participants/ecf"
  end
end
