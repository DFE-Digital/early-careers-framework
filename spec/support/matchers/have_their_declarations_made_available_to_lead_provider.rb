# frozen_string_literal: true

module Support
  module HaveTheirDeclarationsMadeAvailableToLeadProvider
    extend RSpec::Matchers::DSL

    RSpec::Matchers.define :have_their_declarations_made_available_to do |lead_provider_name|
      match do |participant_name|
        declarations_endpoint = APIs::ParticipantDeclarationsEndpoint.new(tokens[lead_provider_name])
        declarations_endpoint.can_access_participant_declarations?(participants[participant_name])
      end

      failure_message do |participant_name|
        "#{participant_name}'s declarations are not available to #{lead_provider_name}"
      end

      failure_message_when_negated do |participant_name|
        "#{participant_name}'s declarations are available to #{lead_provider_name}"
      end

      description do
        "have their declarations made available to #{lead_provider_name}"
      end
    end
  end
end
