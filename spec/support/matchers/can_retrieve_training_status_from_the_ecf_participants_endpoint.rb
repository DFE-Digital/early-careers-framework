# frozen_string_literal: true

module Support
  module CanRetrieveTrainingStatusFromTheEcfParticipantsEndpoint
    extend RSpec::Matchers::DSL

    RSpec::Matchers.define :be_able_to_retrieve_the_training_status_of_the_participant_from_the_ecf_participants_endpoint do |participant_name, training_status|
      match do |lead_provider_name|
        @error = nil
        @text = ""

        user = User.find_by(full_name: participant_name)
        raise "Could not find User for #{participant_name}" if user.nil?

        participant = user.participant_profiles.first
        raise "Could not find ParticipantProfile for #{participant_name}" if participant.nil?

        declarations_endpoint = APIs::ECFParticipantsEndpoint.new(tokens[lead_provider_name])
        attributes = declarations_endpoint.get_participant_details(participant)

        if attributes["training_status"].to_sym == training_status
          true
        else
          @text = JSON.generate(attributes)
          @error = attributes["training_status"]
          false
        end
      end

      failure_message do |lead_provider_name|
        "'#{lead_provider_name}' Should have been able to retrieve the training status '#{training_status}' but got '#{@error}' for '#{participant_name}' in the response from the ecf participants endpoint\n===\n#{@text}\n==="
      end

      failure_message_when_negated do |lead_provider_name|
        "'#{lead_provider_name}' Should not have been able to retrieve the training status '#{training_status}' for '#{participant_name}' in the response from the ecf participants endpoint\n===\n#{@text}\n==="
      end

      description do
        "be able to retrieve the training status '#{training_status}' of '#{participant_name}' from the ecf participants endpoint"
      end
    end
  end
end
