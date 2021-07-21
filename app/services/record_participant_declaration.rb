# frozen_string_literal: true

require "json_schema/validate_body_against_schema"

class RecordParticipantDeclaration
  attr_accessor :params

  class << self
    def call(params)
      new(params).call
    end

    def required_params
      %i[participant_id cpd_lead_provider declaration_type declaration_date course_identifier raw_event]
    end
  end

  def call
    validate_schema!
    add_participant_profile_params!
    declaration = create_record!
    validate_provider!
    { id: declaration.id }
  end

private

  delegate :participant?, :early_career_teacher?, :mentor?, :npq?, to: :user, allow_nil: true
  delegate :early_career_teacher_profile, :mentor_profile, :npq_profiles, to: :user
  delegate :school, :cohort, to: :user_profile

  def initialize(params)
    @params = params
    @params[:user_id] = params[:participant_id]
  end

  def validate_schema!
    errors = JsonSchema::ValidateBodyAgainstSchema.call(schema: schema, body: params[:raw_event])
    raise ActionController::ParameterMissing, (errors.map { |error| error.sub(/\sin schema.*$/, "") }) unless errors.empty?
  end

  def schema
    JSON.parse(File.read(JsonSchema::VersionEventFileName.call(version: "0.3")))
  end

  def add_participant_profile_params!
    raise ActionController::ParameterMissing, [I18n.t(:invalid_participant)] unless participant? || npq?
    raise ActionController::ParameterMissing, [I18n.t(:invalid_course)] unless course_valid_for_participant?
  end

  def user_id
    params[:user_id]
  end

  def course
    params[:course_identifier]
  end

  def user
    @user ||= User.find_by(id: user_id)
  end

  def course_valid_for_participant?
    early_career_teacher? && course == "ecf-induction" ||
      mentor? && course == "ecf-mentor" ||
      npq? && npq_course?
  end

  def npq_course?
    %w[npq-leading-teaching
       npq-leading-teaching-development
       npq-leading-behaviour-culture
       npq-headship
       npq-senior-leadership
       npq-executive-leadership].include?(course)
  end

  def user_profile
    if early_career_teacher?
      early_career_teacher_profile
    elsif mentor?
      mentor_profile
    elsif npq?
      npq_profiles.includes({ validation_data: [:npq_course] }).where('npq_courses.identifier': course).first
    else
      false
    end
  end

  def declaration_type
    if npq? && npq_course?
      ParticipantDeclaration::NPQ
    elsif early_career_teacher? || mentor?
      ParticipantDeclaration::ECF
    end
  end

  def create_record!
    ActiveRecord::Base.transaction do
      declaration_type.create!(params.slice(*required_params)).tap do |participant_declaration|
        ProfileDeclaration.create!(
          participant_declaration: participant_declaration,
          participant_profile: user_profile,
        )
      end
    end
  end

  def lead_provider_from_token
    params[:cpd_lead_provider]
  end

  def actual_lead_provider
    SchoolCohort.find_by(school: school, cohort: cohort)&.lead_provider&.cpd_lead_provider if early_career_teacher? || mentor?
    user_profile.validation_data.npq_lead_provider.cpd_lead_provider if npq?
  end

  def validate_provider!
    raise ActionController::ParameterMissing, I18n.t(:invalid_participant) unless actual_lead_provider.nil? || lead_provider_from_token == actual_lead_provider
  end

  def required_params
    (self.class.required_params - [:participant_id] + [:user_id])
  end
end
