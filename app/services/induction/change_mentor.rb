# frozen_string_literal: true

class Induction::ChangeMentor < BaseService
  def call
    ActiveRecord::Base.transaction do
      Induction::ChangeInductionRecord.call(
        induction_record:,
        changes: { mentor_profile: },
      )
      induction_record.participant_profile.update!(mentor_profile:)

      send_training_materials_if_needed

      mentor_profile&.user&.touch
    end
  end

private

  attr_reader :mentor_profile, :induction_record

  def initialize(induction_record:, mentor_profile: nil)
    @induction_record = induction_record
    @mentor_profile = mentor_profile
  end

  def send_training_materials
    MentorMailer.with(
      mentor_email: mentor_profile.user.email,
      mentor_name: mentor_profile.user.full_name,
      school_name: induction_record.school.name,
      ect_name: induction_record.participant_profile.user.full_name,
      lead_provider_name: induction_record.lead_provider.name,
      sit_name: induction_record.school.induction_tutor.full_name,
    ).training_materials.deliver_later
  end

  def materials(profile)
    profile.school_cohort.default_induction_programme&.core_induction_programme&.name
  end

  def sit_name
    induction_record.school.induction_tutor&.full_name
  end

  def send_training_materials_if_needed
    return unless mentor_profile&.school_cohort
    return unless sit_name

    # CIP and CIP but different materials
    if mentor_profile.school_cohort.cip? &&
        induction_record.participant_profile.school_cohort.cip? &&
        materials(mentor_profile).present? &&
        (materials(mentor_profile) != materials(induction_record.participant_profile))
      send_training_materials
    end

    # Mentor at FIP school but mentor is CIP ECT
    if mentor_profile.school_cohort.fip? && induction_record.participant_profile.school_cohort.cip?
      send_training_materials
    end
  end
end
