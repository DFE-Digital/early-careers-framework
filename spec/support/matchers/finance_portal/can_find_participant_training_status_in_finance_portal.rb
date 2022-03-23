# frozen_string_literal: true

module Support
  module FindingParticipantTrainingStatusInFinancePortal
    extend RSpec::Matchers::DSL

    RSpec::Matchers.define :be_able_to_find_the_training_status_of_the_participant_in_the_finance_portal do |participant_name, training_status|
      match do |finance_user|
        sign_in_as finance_user
        @error = nil

        user = User.find_by(full_name: participant_name)
        raise "Could not find User for #{participant_name}" if user.nil?

        participant = user.participant_profiles.first
        raise "Could not find ParticipantProfile for #{participant_name}" if participant.nil?

        portal = Pages::FinancePortal.new
        search = portal.view_participant_drilldown
        drilldown = search.find participant_name
        @text = page.find("main").text

        @error = :id unless drilldown.can_see_participant?(user.id)
        @error = :status unless drilldown.can_see_training_status?(training_status)

        sign_out

        if @error.nil?
          true
        else
          false
        end
      end

      failure_message do |_sit|
        "the training status of '#{training_status}' for '#{participant_name}' cannot be found within:\n===\n#{@text}\n==="
      end

      failure_message_when_negated do |_sit|
        "the training status of '#{training_status}' for '#{participant_name}' can be found within:\n===\n#{@text}\n==="
      end

      description do
        "be able to find the training status of '#{training_status}' for '#{participant_name}' in the finance portal"
      end
    end
  end
end
