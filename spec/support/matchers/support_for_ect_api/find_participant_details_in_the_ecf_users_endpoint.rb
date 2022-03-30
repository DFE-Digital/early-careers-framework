# frozen_string_literal: true

module Support
  module BeReportedToSupportForECTsAs
    extend RSpec::Matchers::DSL

    RSpec::Matchers.define :find_participant_details_in_the_ecf_users_endpoint do |participant_name, participant_email, programme, participant_type|
      match do |_service_name|
        user = User.find_by(full_name: participant_name)
        raise "Could not find User for #{participant_name}" if user.nil?

        user_endpoint = APIs::ECFUsersEndpoint.new
        user_endpoint.get_user user.id

        @text = user_endpoint.response

        user_endpoint.has_full_name? participant_name
        user_endpoint.has_email? participant_email
        user_endpoint.has_user_type? participant_type == "ECT" ? "early_career_teacher" : "mentor"
        user_endpoint.has_core_induction_programme? "none"
        user_endpoint.has_induction_programme_choice? programme == "CIP" ? "core_induction_programme" : "full_induction_programme"

        true
      rescue Capybara::ElementNotFound
        false
      end

      failure_message do |service_name|
        "'#{service_name}' should have been able to retrieve the record for \"#{participant_name}\", an #{participant_type} on the #{programme} programme, within\n===\n#{@text}\n==="
      end

      failure_message_when_negated do |service_name|
        "'#{service_name}' should not have been able to retrieve the record for \"#{participant_name}\", an #{participant_type} on the #{programme} programme, within\n===\n#{@text}\n==="
      end

      description do
        "be able to retrieve the record for \"#{participant_name}\", an #{participant_type} on the #{programme} programme"
      end
    end
  end
end
