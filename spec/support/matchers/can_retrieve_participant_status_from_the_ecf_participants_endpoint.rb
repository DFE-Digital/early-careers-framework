# frozen_string_literal: true

module Support
  module CanRetrieveParticipantStatusFromTheEcfParticipantsEndpoint
    extend RSpec::Matchers::DSL

    RSpec::Matchers.define :be_able_to_retrieve_the_status_of_the_participant_from_the_ecf_participants_endpoint do |participant_name, status|
      match do |lead_provider_name|
        @error = nil
        @text = ""

        user = User.find_by(full_name: participant_name)
        throw "Could not find User for #{participant_name}" if user.nil?
        participant = user.participant_profiles.first

        declarations_endpoint = APIs::ECFParticipantsEndpoint.new(tokens[lead_provider_name])
        attributes = declarations_endpoint.get_participant_details(participant)

        if attributes["status"].to_sym == status
          true
        else
          @text = JSON.generate(attributes)
          @error = attributes["status"]
          false
        end
      end

      failure_message do |lead_provider_name|
        "'#{lead_provider_name}' Should have been able to retrieve the status '#{status}' but got '#{@error}' for '#{participant_name}' in the response from the ecf participants endpoint\n===\n#{@text}\n==="
      end

      failure_message_when_negated do |lead_provider_name|
        "'#{lead_provider_name}' Should not have been able to retrieve the status '#{status}' for '#{participant_name}' in the response from the ecf participants endpoint\n===\n#{@text}\n==="
      end

      description do
        "be able to retrieve the status '#{status}' of '#{participant_name}' from the ecf participants endpoint"
      end
    end
  end
end
