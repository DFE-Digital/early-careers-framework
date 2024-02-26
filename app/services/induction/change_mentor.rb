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
      mentor_profile:,
      ect_name: induction_record.participant_profile.user.full_name,
      cip_materials_name: cip_materials.name,
      sit_name:,
    ).training_materials
     .deliver_later
  end

  def cip_materials
    induction_record.induction_programme.core_induction_programme
  end

  def sit_name
    induction_record.school.induction_tutor&.full_name
  end

  def send_training_materials_if_needed
    return unless sit_name

    if induction_record.enrolled_in_cip? && cip_materials.present?
      send_training_materials
    end
  end
end
