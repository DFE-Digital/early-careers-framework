# frozen_string_literal: true

module Support
  module CanFindParticipantDetailsInAdminSupportPortal
    extend RSpec::Matchers::DSL

    RSpec::Matchers.define :be_able_to_find_participant_details_in_support_portal do |participant_name, sit_name|
      match do |admin_user|
        sit = User.find_by(full_name: sit_name)
        raise "Could not find User for #{sit_name}" if sit.nil?

        school = sit.induction_coordinator_profile.schools.first
        raise "Could not find School for #{sit_name}" if school.nil?

        @school_name = school.name

        sign_in_as admin_user

        click_on "Participants"

        click_on participant_name

        @text = page.find("main").text
        has_text? "#{participant_name} Eligible to start"
        has_text? "Full name #{participant_name}"
        has_text? "School #{@school_name}"

        sign_out

        true
      rescue Capybara::ElementNotFound
        @text = page.find("main").text
        false
      end

      failure_message do |_admin_user|
        "the details of '#{participant_name}' cannot be found at '#{@school_name}' within:\n===\n#{@text}\n==="
      end

      failure_message_when_negated do |_admin_user|
        "the details of '#{participant_name}' can be found at '#{@school_name}' within:\n===\n#{@text}\n==="
      end

      description do
        "be able to find the details of '#{participant_name}' in the school induction portal"
      end
    end
  end
end
