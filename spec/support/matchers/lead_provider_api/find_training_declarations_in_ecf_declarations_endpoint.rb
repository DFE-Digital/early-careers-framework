# frozen_string_literal: true

module Support
  module HaveTheirDeclarationsMadeAvailableToLeadProvider
    extend RSpec::Matchers::DSL

    RSpec::Matchers.define :find_training_declarations_in_ecf_declarations_endpoint do |participant_name, declaration_types|
      match do |lead_provider_name|
        user = User.find_by(full_name: participant_name)
        raise "Could not find User for #{participant_name}" if user.nil?

        participant = user.participant_profiles.first
        raise "Could not find ParticipantProfile for #{participant_name}" if participant.nil?

        declarations_endpoint = APIs::GetParticipantDeclarationsEndpoint.new tokens[lead_provider_name]
        declarations_endpoint.get_training_declarations user.id

        @text = JSON.pretty_generate declarations_endpoint.response

        declarations_endpoint.has_declarations? declaration_types
        declaration_types.each do |declaration_type|
          declarations_endpoint.get_declaration declaration_type
        end

        true
      rescue Capybara::ElementNotFound => e
        @error = e
        false
      end

      failure_message do |lead_provider_name|
        return @error unless @error.nil?

        "'#{lead_provider_name}' should have been able to retrieve the declarations #{declaration_types} for the training of '#{participant_name}' within:\n===\n#{@text}\n==="
      end

      failure_message_when_negated do |lead_provider_name|
        "'#{lead_provider_name}' should not have been able to retrieve the declarations #{declaration_types} for the training of '#{participant_name}' within:\n===\n#{@text}\n==="
      end

      description do
        if declaration_types.any?
          "be able to retrieve the declarations #{declaration_types} for the training of '#{participant_name}' from the ecf declarations endpoint"
        else
          "not be able to retrieve any declarations for the training of '#{participant_name}' from the ecf declarations endpoint"
        end
      end
    end
  end
end
