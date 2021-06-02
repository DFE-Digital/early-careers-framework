# frozen_string_literal: true

class RecordParticipantEvent
  include InitializeWithConfig
  class << self
    def required_params
      %i[participant_uuid lead_provider declaration_type declaration_date raw_event]
    end
  end

  def call
    ( set_config_ect_profile || :not_found ) &&
      ( create_record || :unprocessable_entity ) &&
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
    config[:early_career_teacher_profile]=user_model.find(participant_uuid)&.early_career_teacher_profile
  end

  def create_record
    recorder.create(config.slice(*required_params))
  end

  def required_params
    (self.class.required_params - [:participant_uuid]) << :early_career_teacher_profile
  end

end
