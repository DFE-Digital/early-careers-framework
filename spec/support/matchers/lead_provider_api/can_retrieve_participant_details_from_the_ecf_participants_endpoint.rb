# frozen_string_literal: true

module Support
  module CanRetrieveParticipantDetailsFromTheEcfParticipantsEndpoint
    extend RSpec::Matchers::DSL

    RSpec::Matchers.define :be_able_to_retrieve_the_details_of_the_participant_from_the_ecf_participants_endpoint do |participant_name, participant_type|
      match do |lead_provider_name|
        @expected = nil

        user = User.find_by(full_name: participant_name)
        raise "Could not find User for #{participant_name}" if user.nil?

        participant_profile = user.participant_profiles.first
        raise "Could not find ParticipantProfile for #{participant_name}" if participant_profile.nil?

        declarations_endpoint = APIs::ECFParticipantsEndpoint.new(tokens[lead_provider_name])
        attributes = declarations_endpoint.get_participant_details(participant_profile)

        @text = JSON.pretty_generate attributes

        @expected = user.email unless attributes["email"] == user.email
        @expected = participant_name unless attributes["full_name"] == participant_name
        @expected = participant_profile.school.urn unless attributes["school_urn"] == participant_profile.school.urn
        @expected = participant_type.downcase unless attributes["participant_type"] == participant_type.downcase

        @expected.nil?
      end

      failure_message do |lead_provider_name|
        "'#{lead_provider_name}' should have been able to see '#{@expected}' for '#{participant_name}' within:\n===\n#{@text}\n==="
      end

      failure_message_when_negated do |lead_provider_name|
        "'#{lead_provider_name}' should not have been able to see the details of '#{participant_name}' within:\n===\n#{@text}\n==="
      end

      description do
        "be able to retrieve the details of the #{participant_type} '#{participant_name}' from the ecf participants endpoint"
      end
    end
  end
end
