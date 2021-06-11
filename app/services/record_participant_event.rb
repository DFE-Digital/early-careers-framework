# frozen_string_literal: true

require "has_di_parameters"
require "json_schema/validate_body_against_schema"

class RecordParticipantEvent
  include HasDIParameters
  required_params :participant_id, :lead_provider, :declaration_type, :declaration_date, :raw_event

  class << self
    def call(params)
      new(params).call
    end
  end

  def call
    validate_schema!
    return :not_found unless add_ect_profile_params
    return :unprocessable_entity unless create_record
    return :not_found unless valid_provider

    :no_content
  end

private

  def initialize(params)
    inject_params(params)
  end

  def default_params
    {
      recorder: ParticipantDeclaration,
      user_model: User,
      schema_validator: JsonSchema::ValidateBodyAgainstSchema,
      json_schema_file_location: JsonSchema::VersionEventFileName,
    }
  end

  def validate_schema!
    errors = schema_validator.call(schema: schema, body: raw_event)
    raise ActionController::ParameterMissing, errors unless errors.empty?

    true
  end

  def schema
    JSON.parse(File.read(json_schema_file_location.call(version: "0.2")))
  end

  def add_ect_profile_params
    params[:early_career_teacher_profile] = early_career_teacher_profile
  end

  def early_career_teacher_profile
    user_model.find(participant_id)&.early_career_teacher_profile
  end

  def create_record
    recorder.create(params.slice(*required_params))
  end

  def actual_lead_provider
    SchoolCohort.find_by(school: early_career_teacher_profile.school, cohort: early_career_teacher_profile.cohort)&.lead_provider
  end

  def valid_provider
    actual_lead_provider.nil? || lead_provider == actual_lead_provider
  end

  def required_params
    (self.class.required_params - [:participant_id]) << :early_career_teacher_profile
  end
end
