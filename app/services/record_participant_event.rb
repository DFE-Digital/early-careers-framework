# frozen_string_literal: true

class RecordParticipantEvent
  include InitializeWithConfig
  class << self
    def required_params
      %i[participant_id lead_provider declaration_type declaration_date raw_event]
    end
  end

  def call
    ( set_config_ect_profile || :not_found ) &&
      ( create_record || :unprocessable_entity ) &&
      ( invalid_provider || :unprocessable_entity ) &&
      :no_content
  end

private
  def default_config
    HashWithIndifferentAccess.new(
      recorder: ParticipantDeclaration,
      user_model: User,
      )
  end

  def set_config_ect_profile
    config[:early_career_teacher_profile]=early_career_teacher_profile
  end

  def early_career_teacher_profile
    user_model.find(participant_id)&.early_career_teacher_profile
  end

  def create_record
    recorder.create(config.slice(*required_params))
  end

  def actual_lead_provider
    SchoolCohort.find_by(school: early_career_teacher_profile.school, cohort: early_career_teacher_profile.cohort)&.lead_provider
  end

  def invalid_provider
    actual_lead_provider.nil? || lead_provider != actual_lead_provider
  end

  def required_params
    (self.class.required_params - [:participant_id]) << :early_career_teacher_profile
  end
end
