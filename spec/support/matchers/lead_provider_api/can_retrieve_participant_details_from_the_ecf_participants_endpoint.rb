# frozen_string_literal: true

module Support
  module CanRetrieveParticipantDetailsFromTheEcfParticipantsEndpoint
    extend RSpec::Matchers::DSL

    RSpec::Matchers.define :be_able_to_retrieve_the_details_of_the_participant_from_the_ecf_participants_endpoint do |participant_name, participant_type, options = {}|
      match do |lead_provider_name|
        user = User.find_by(full_name: participant_name)
        raise "Could not find User for #{participant_name}" if user.nil?

        participant_profile = user.participant_profiles.first
        raise "Could not find ParticipantProfile for #{participant_name}" if participant_profile.nil?

        school = participant_profile.school
        raise "Could not find School for #{participant_name}" if school.nil?

        declarations_endpoint = APIs::ECFParticipantsEndpoint.new(tokens[lead_provider_name], options[:experimental])
        declarations_endpoint.get_participant user.id

        declarations_endpoint.has_full_name? participant_name
        declarations_endpoint.has_email? user.email
        declarations_endpoint.has_school_urn? school.urn
        declarations_endpoint.has_participant_type? participant_type.to_s.downcase

        true
      rescue Capybara::ElementNotFound
        @text = declarations_endpoint.response
        false
      end

      failure_message do |lead_provider_name|
        "'#{lead_provider_name}' Should have been able to retrieve the participant details for \"#{participant_name}\" within\n===\n#{@text}\n==="
      end

      failure_message_when_negated do |lead_provider_name|
        "'#{lead_provider_name}' Should not have been able to retrieve the participant details for \"#{participant_name}\" within\n===\n#{@text}\n==="
      end

      description do
        "be able to retrieve the participant details for \"#{participant_name}\" from the ecf participants endpoint"
      end
    end
  end
end
