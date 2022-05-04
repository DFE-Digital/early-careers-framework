# frozen_string_literal: true

module Support
  module CanFindParticipantDetailsInAdminSupportPortal
    extend RSpec::Matchers::DSL

    RSpec::Matchers.define :find_participant_details_in_support_portal do |participant_name, sit_name|
      match do |admin_user|
        sit = User.find_by(full_name: sit_name)
        raise "Could not find User for #{sit_name}" if sit.nil?

        school = sit.induction_coordinator_profile.schools.first
        raise "Could not find School for #{sit_name}" if school.nil?

        @school_name = school.name

        sign_in_as admin_user

        portal = Pages::AdminSupportPortal.new
        list = portal.view_participant_list
        participant_detail = list.view_participant participant_name

        @text = page.find("main").text

        participant_detail.can_see_eligible_to_start? participant_name
        participant_detail.can_see_full_name? participant_name
        participant_detail.can_see_school? @school_name

        sign_out

        true
      rescue Capybara::ElementNotFound => e
        @error = e

        sign_out

        false
      end

      failure_message do |_admin_user|
        return @error unless @error.nil?

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
