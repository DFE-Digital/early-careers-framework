# frozen_string_literal: true

module Support
  module FindingParticipantStatusInSchoolsInductionPortal
    extend RSpec::Matchers::DSL

    RSpec::Matchers.define :be_able_to_find_the_participant_status_in_the_school_induction_portal do |participant_name, status|
      match do |sit|
        sign_in_as sit.user

        induction_dashboard = Pages::SITInductionDashboard.new
        participants_dashboard = induction_dashboard.view_participant_dashboard
        participant_details = participants_dashboard.view_participant participant_name

        participant_details.can_see_status?(status.to_s)

        sign_out

        true
      rescue Capybara::ElementNotFound
        @text = page.find("main").text
        false
      end

      failure_message do |_sit|
        "the status of '#{status}' for '#{participant_name}' cannot be found within:\n===\n#{@text}\n==="
      end

      failure_message_when_negated do |_sit|
        "the status of '#{status}' for '#{participant_name}' can be found within:\n===\n#{@text}\n==="
      end

      description do
        "be able to find the status of '#{status}' for '#{participant_name}' in the school induction portal"
      end
    end
  end
end
