# frozen_string_literal: true

module Support
  module FindingParticipantDetailsInSchoolsInductionPortal
    extend RSpec::Matchers::DSL

    RSpec::Matchers.define :be_able_to_find_the_details_of_the_participant_in_the_school_induction_portal do |participant_name|
      match do |sit|
        sign_in_as sit.user
        @error = nil

        user = User.find_by(full_name: participant_name)
        throw "Could not find User for #{participant_name}" if user.nil?
        participant = user.participant_profiles.first

        induction_dashboard = Pages::SITInductionDashboard.new
        if induction_dashboard.has_expected_content?(sit)
          if induction_dashboard.has_participants?
            participants_dashboard = induction_dashboard.view_participant_dashboard
            participant_details = participants_dashboard.view_participant participant_name

            @text = page.find("main").text

            @error = :email unless participant_details.can_see_email?(participant.user.email.to_s)
            @error = :full_name unless participant_details.can_see_full_name?(participant_name)
          else
            @error = :no_participants
          end
        else
          @error = :induction_dashboard
        end

        sign_out

        if @error.nil?
          true
        else
          false
        end
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
    end
  end
end
