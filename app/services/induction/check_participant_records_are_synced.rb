# frozen_string_literal: true

class Induction::CheckParticipantRecordsAreSynced < BaseService
  def call
    participant_profiles.each do |profile|
      next unless included_induction_programme?(profile)

      check_induction_programme_change(profile)
      check_status_is_correct(profile)
    end
  end

private

  attr_reader :participant_profiles

  def initialize(participant_profiles:)
    @participant_profiles = Array(participant_profiles)
  end

  def check_induction_programme_change(profile)
    return if profile.induction_records.first.withdrawn?

    if profile.current_induction_record.induction_programme != profile.school_cohort.default_induction_programme
      Rails.logger.info "Programme has changed for #{profile.id}, expecting #{profile.school_cohort.default_induction_programme.id}
            but got #{profile.current_induction_record.induction_programme.id}"
    end
  end

  def check_status_is_correct(profile)
    return if profile.induction_records.first.withdrawn?

    if profile.current_induction_record&.status != profile.status
      Rails.logger.info "Record status has changed for #{profile.id}, expecting #{profile.status}
            but got #{profile.current_induction_record.status}"
    end
  end

  def included_induction_programme?(profile)
    profile.school_cohort.induction_programme_choice.in?(%w[full_induction_programme core_induction_programme design_our_own school_funded_fip])
  end
end
