# frozen_string_literal: true

require_relative "./participants_endpoint"

module APIs
  # noinspection RubyClassModuleNamingConvention
  module V1
    class ECFParticipantsEndpoint < ParticipantsEndpoint
    private

      def url = "/api/v1/participants/ecf"
    end
  end
end
