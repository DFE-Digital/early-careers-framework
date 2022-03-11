# frozen_string_literal: true

module Support
  module HaveTheirDeclarationsMadeAvailableToLeadProvider
    extend RSpec::Matchers::DSL

    RSpec::Matchers.define :be_able_to_retrieve_the_training_declarations_for_the_participant_from_the_ecf_declarations_endpoint do |participant_name, declarations|
      match do |lead_provider_name|
        declarations_endpoint = APIs::ParticipantDeclarationsEndpoint.new(tokens[lead_provider_name])

        user = User.find_by(full_name: participant_name)
        raise "Could not find User for #{participant_name}" if user.nil?

        participant = user.participant_profiles.first
        raise "Could not find ParticipantProfile for #{participant_name}" if participant.nil?

        recorded_declarations = declarations_endpoint.get_training_declarations(participant)

        @text = JSON.pretty_generate recorded_declarations

        @error = nil
        declarations.each_with_index do |declaration_type, index|
          @error = declaration_type unless recorded_declarations[index]["declaration_type"] == declaration_type
        end

        @error.nil?
      end

      failure_message do |lead_provider_name|
        "'#{lead_provider_name}' should have been able to retrieve the declarations #{declarations} for the training of '#{participant_name}' within:\n===\n#{@text}\n==="
      end

      failure_message_when_negated do |lead_provider_name|
        "'#{lead_provider_name}' should not have been able to retrieve the declarations #{declarations} for the training of '#{participant_name}' within:\n===\n#{@text}\n==="
      end

      description do
        if declarations.any?
          "be able to retrieve the declarations #{declarations} for the training of '#{participant_name}' from the ecf declarations endpoint"
        else
          "be able to retrieve no declarations for the training of '#{participant_name}' from the ecf declarations endpoint"
        end
      end
    end
  end
end
