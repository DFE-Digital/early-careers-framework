# frozen_string_literal: true

require "initialize_with_config"
require "json_schema/validate_participant_event"

class RecordParticipantEvent
  include InitializeWithConfig
  required_config :participant_id, :lead_provider, :declaration_type, :declaration_date, :raw_event

  def call
    return :unprocessable_entity unless schema_validation
    return :not_found unless set_config_ect_profile
    return :unprocessable_entity unless create_record
    return :not_found unless valid_provider

    :no_content
  end

private

  def schema_validation
    errors = participant_event_validator.call(config, body: raw_event)
    raise ActionController::ParameterMissing, errors unless errors.empty?

    true
  end

  def default_config
    {
      recorder: ParticipantDeclaration,
      user_model: User,
      participant_event_validator: JsonSchema::ValidateParticipantEvent,
    }
  end

  def set_config_ect_profile
    config[:early_career_teacher_profile] = early_career_teacher_profile
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

  def valid_provider
    actual_lead_provider.nil? || lead_provider == actual_lead_provider
  end

  def required_params
    (self.class.required_config - [:participant_id]) << :early_career_teacher_profile
  end
end
