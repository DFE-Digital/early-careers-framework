# frozen_string_literal: true

module Support
  module CanRetrieveTrainingStatusFromTheEcfParticipantsEndpoint
    extend RSpec::Matchers::DSL

    RSpec::Matchers.define :be_able_to_retrieve_the_training_status_of_the_participant_from_the_ecf_participants_endpoint do |participant_name, training_status, options = {}|
      match do |lead_provider_name|
        user = User.find_by(full_name: participant_name)
        raise "Could not find User for #{participant_name}" if user.nil?

        declarations_endpoint = APIs::ECFParticipantsEndpoint.new(tokens[lead_provider_name], options[:experimental])
        declarations_endpoint.get_participant user.id

        @text = declarations_endpoint.response

        declarations_endpoint.has_training_status? training_status.to_s
      end

      failure_message do |lead_provider_name|
        "'#{lead_provider_name}' Should have been able to retrieve the \"training status\" of \"#{training_status}\" for \"#{participant_name}\" within\n===\n#{@text}\n==="
      end

      failure_message_when_negated do |lead_provider_name|
        "'#{lead_provider_name}' Should not have been able to retrieve the \"training status\" of \"#{training_status}\" for \"#{participant_name}\" within\n===\n#{@text}\n==="
      end

      description do
        "be able to retrieve the \"training status\" of \"#{training_status}\" for \"#{participant_name}\" from the ecf participants endpoint"
      end
    end
  end
end
