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

    def user_type_profile_recorders
      {
        early_career_teacher_profile: EarlyCareerTeacherProfileDeclaration,
        mentor_profile: MentorProfileDeclaration,
      }
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
    @params[:user_id] = params[:participant_id]
  end

  def validate_schema!
    errors = JsonSchema::ValidateBodyAgainstSchema.call(schema: schema, body: @params[:raw_event])
    raise ActionController::ParameterMissing, (errors.map { |error| error.sub(/\sin schema.*$/, "") }) unless errors.empty?
  end

  def schema
    JSON.parse(File.read(JsonSchema::VersionEventFileName.call(version: "0.2")))
  end

  def add_ect_profile_params!
    raise ActionController::ParameterMissing, I18n.t(:invalid_participant) unless user && profile_type
  end

  def user_id
    params[:user_id]
  end

  def user
    @user ||= User.find_by(id: user_id)
  end

  def profile_type
    if user.early_career_teacher?
      :early_career_teacher_profile
    elsif user.mentor?
      :mentor_profile
    else
      false
    end
  end

  def user_profile
    case
    when user.early_career_teacher?
      user.early_career_teacher_profile
    when user.mentor?
      user.mentor_profile
    else
      false
    end
  end

  def create_record
    ActiveRecord::Base.transaction do
      participant_declaration = ParticipantDeclaration.create(params.slice(*required_params))
      ProfileDeclaration.create!(
        participant_declaration: participant_declaration,
        lead_provider: lead_provider,
        declarable: self.class.user_type_profile_recorders[profile_type].new(profile_type=>user_profile)
      )
    end
  end

  def lead_provider
    params[:lead_provider]
  end

  def actual_lead_provider
    SchoolCohort.find_by(school: user_profile.school, cohort: user_profile.cohort)&.lead_provider
  end

  def validate_provider!
    raise ActionController::ParameterMissing, I18n.t(:invalid_participant) unless actual_lead_provider.nil? || lead_provider == actual_lead_provider
  end

  def required_params
    (self.class.required_params - [:participant_id] + [:user_id])
  end
end
