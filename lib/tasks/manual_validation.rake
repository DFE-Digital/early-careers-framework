# frozen_string_literal: true

desc "Manual tasks related to validation"
namespace :manual_validation do
  desc "Re-run eligibility checks for those without QTS"
  task qts_eligibility: :environment do
    ParticipantProfile::ECT.current_cohort
                           .active_record
                           .joins(:ecf_participant_eligibility)
                           .where(ecf_participant_eligibility: { status: "manual_check", reason: "no_qts" })
                           .each do |profile|
      Participants::ParticipantValidationForm.call(profile)
    end
  end

  desc "Re-run eligibility checks for those with a previous induction (NQT+1)"
  task previous_induction_eligibility: :environment do
    ParticipantProfile::ECT.current_cohort
                           .active_record
                           .joins(:ecf_participant_eligibility)
                           .where(ecf_participant_eligibility: { status: "induction", reason: "previous_induction" })
                           .each do |profile|
      Participants::ParticipantValidationForm.call(profile)
    end
  end
end
