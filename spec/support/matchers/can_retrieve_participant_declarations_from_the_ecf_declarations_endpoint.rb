# frozen_string_literal: true

module Support
  module HaveTheirDeclarationsMadeAvailableToLeadProvider
    extend RSpec::Matchers::DSL

    RSpec::Matchers.define :be_able_to_retrieve_the_training_declarations_for_the_participant_from_the_ecf_declarations_endpoint do |participant_name|
      match do |lead_provider_name|
        declarations_endpoint = APIs::ParticipantDeclarationsEndpoint.new(tokens[lead_provider_name])

        user = User.find_by(full_name: participant_name)
        throw "Could not find User for #{participant_name}" if user.nil?
        participant = user.participant_profiles.first

        declarations_endpoint.can_access_participant_declarations?(participant)
      end

      failure_message do |lead_provider_name|
        "'#{lead_provider_name}' Should have been able to retrieve the declarations for the training of '#{participant_name}' when #{lead_provider_name} calls the ecf participants endpoint"
      end

      failure_message_when_negated do |lead_provider_name|
        "'#{lead_provider_name}' Should not have been able to retrieve the declarations for the training of '#{participant_name}' when #{lead_provider_name} calls the ecf participants endpoint"
      end

      description do
        "be able to retrieve the declarations for the training of '#{participant_name}' from the ecf declarations endpoint"
      end
    end
  end
end
