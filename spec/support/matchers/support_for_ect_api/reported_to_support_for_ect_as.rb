# frozen_string_literal: true

module Support
  module BeReportedToSupportForECTsAs
    extend RSpec::Matchers::DSL

    RSpec::Matchers.define :be_able_to_retrieve_the_details_of_the_participant_from_the_ecf_users_endpoint do |participant_name, programme, participant_type|
      match do |_service_name|
        user_endpoint = APIs::ECFUsersEndpoint.new

        user = User.find_by(full_name: participant_name)
        raise "Could not find User for #{participant_name}" if user.nil?

        participant = user.participant_profiles.first
        raise "Could not find ParticipantProfile for #{participant_name}" if participant.nil?

        case programme
        when "FIP"
          user_endpoint.user_is_fip_ect?(participant)
        when "CIP"
          user_endpoint.user_is_cip_ect?(participant)
        end
      end

      failure_message do |service_name|
        "#{service_name} should have been able to retrieve the record for '#{participant_name}' reporting them as an #{participant_type} on the #{programme} programme"
      end

      failure_message_when_negated do |service_name|
        "#{service_name} should not have been able to retrieve the record for '#{participant_name}' reporting them as an #{participant_type} on the #{programme} programme"
      end

      description do
        "be able to retrieve the record for '#{participant_name}' reporting them as an #{participant_type} on the #{programme} programme"
      end
    end
  end
end
