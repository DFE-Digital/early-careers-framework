# frozen_string_literal: true

namespace :eligibility do
  desc "Re-run all eligibility checks for eligible ects"
  task :re_run_ect_validations, %i[last_validated_before] => :environment do |_task, args|
    last_validated_before = Time.zone.at(args[:last_validated_before])
    ParticipantProfile::ECT.joins(:ecf_participant_eligibility).merge(ECFParticipantEligibility.updated_before(last_validated_before).eligible_status)
      .find_each do |participant_profile|
      Participants::ParticipantValidationForm.call(participant_profile)
      participant_profile.ecf_participant_eligibility.touch
    end
  end
end
