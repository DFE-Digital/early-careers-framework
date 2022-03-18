# frozen_string_literal: true

module Support
  module FindingParticipantDetailsInSchoolsInductionPortal
    extend RSpec::Matchers::DSL

    RSpec::Matchers.define :be_able_to_find_the_details_of_the_participant_in_the_school_induction_portal do |participant_name|
      match do |sit|
        sign_in_as sit.user

        induction_dashboard = Pages::SITInductionDashboard.new
        participants_dashboard = induction_dashboard.view_participant_dashboard
        participant_details = participants_dashboard.view_participant participant_name

        participant_details.can_see_email? email_for(participant_name)
        participant_details.can_see_full_name? participant_name

        sign_out

        true
      rescue Capybara::ElementNotFound
        @text = page.find("main").text
        false
      end

      failure_message do |_sit|
        "the details of '#{participant_name}' cannot be found within:\n===\n#{@text}\n==="
      end

      failure_message_when_negated do |_sit|
        "the details of '#{participant_name}' can be found within:\n===\n#{@text}\n==="
      end

      description do
        "be able to find the details of '#{participant_name}' in the school induction portal"
      end

    private

      def email_for(participant_name)
        user = User.find_by(full_name: participant_name)
        raise "Could not find User for #{participant_name}" if user.nil?

        user.email.to_s
      end
    end
  end
end
