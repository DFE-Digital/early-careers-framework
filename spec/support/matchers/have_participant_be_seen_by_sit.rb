# frozen_string_literal: true

module Support
  module HaveParticipantBeSeenBySIT
    extend RSpec::Matchers::DSL

    RSpec::Matchers.define :be_seen_by_sit do |sit_name|
      match do |participant_name|
        sign_in_as sits[sit_name].user

        induction_dashboard = Pages::SITInductionDashboard.new
        induction_dashboard.has_expected_content?(sits[sit_name]) &&
          if induction_dashboard.has_participants?
            participants_dashboard = induction_dashboard.navigate_to_participants_dashboard

            participants_dashboard.has_expected_content? &&
              participants_dashboard.can_view_participants?(participants[participant_name])
          else
            false
          end
      end

      failure_message do |participant_name|
        "#{participant_name} cannot be seen by #{sit_name}"
      end

      failure_message_when_negated do |participant_name|
        "#{participant_name} can be seen by #{sit_name}"
      end

      description do
        "be seen on the SIT Induction Dashboard by #{sit_name}"
      end
    end
  end
end
