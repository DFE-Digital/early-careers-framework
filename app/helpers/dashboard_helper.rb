# frozen_string_literal: true

module DashboardHelper
  def format_type(participant_type)
    case participant_type
    when :ect
      "ECT"
    when :mentor
      "Mentor"
    else
      participant_type
    end
  end

  def latest_email_delivered_for(profile)
    Email.associated_with(profile).tagged_with(:request_for_details)&.latest&.delivered?
  end

  def latest_email_failed_for(profile)
    Email.associated_with(profile).tagged_with(:request_for_details)&.latest&.failed?
  end

  def participants_active?(profiles)
    profiles.eligible.any? || profiles.contacted_for_info.any? || profiles.details_being_checked.any? || profiles.no_qts_participants.any?
  end
end
