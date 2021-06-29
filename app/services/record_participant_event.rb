# frozen_string_literal: true

require "json_schema/validate_body_against_schema"

class RecordParticipantEvent
  attr_accessor :params

  class << self
    def call(params)
      new(params).call
    end

    def required_params
      %i[participant_id lead_provider declaration_type declaration_date raw_event]
    end
  end

  def call
    validate_schema!
    add_ect_profile_params!
    declaration = create_record!
    validate_provider!
    { id: declaration.id }
  end

private

  def initialize(params)
    @params = params
  end

  def validate_schema!
    errors = JsonSchema::ValidateBodyAgainstSchema.call(schema: schema, body: @params[:raw_event])
    raise ActionController::ParameterMissing, (errors.map { |error| error.sub(/\sin schema.*$/, "") }) unless errors.empty?
  end

  def schema
    JSON.parse(File.read(JsonSchema::VersionEventFileName.call(version: "0.2")))
  end

  def add_ect_profile_params!
    raise ActionController::ParameterMissing, I18n.t(:invalid_participant) unless early_career_teacher_profile

    @params[:early_career_teacher_profile] = early_career_teacher_profile
  end

  def early_career_teacher_profile
    ParticipantProfile::ECT.find_by(user_id: params[:participant_id])
  end

  def create_record!
    ParticipantDeclaration.create!(@params.slice(*required_params))
  end

  def lead_provider
    params[:lead_provider]
  end

  def actual_lead_provider
    SchoolCohort.find_by(school: early_career_teacher_profile.school, cohort: early_career_teacher_profile.cohort)&.lead_provider
  end

  def validate_provider!
    raise ActionController::ParameterMissing, I18n.t(:invalid_participant) unless actual_lead_provider.nil? || lead_provider == actual_lead_provider
  end

  def required_params
    (self.class.required_params - [:participant_id]) << :early_career_teacher_profile
  end
end
