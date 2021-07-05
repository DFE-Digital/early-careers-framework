# frozen_string_literal: true

require "json_schema/validate_body_against_schema"

class RecordParticipantDeclaration
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
    add_participant_profile_params!
    declaration = create_record!
    validate_provider!
    { id: declaration.id }
  end

private

  delegate :participant?, :early_career_teacher?, :mentor?, to: :user, allow_nil: true
  delegate :early_career_teacher_profile, :mentor_profile, to: :user
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
    JSON.parse(File.read(JsonSchema::VersionEventFileName.call(version: "0.2")))
  end

  def add_participant_profile_params!
    raise ActionController::ParameterMissing, I18n.t(:invalid_participant) unless participant?
  end

  def user_id
    params[:user_id]
  end

  def user
    @user ||= User.find_by(id: user_id)
  end

  def user_profile
    if early_career_teacher?
      early_career_teacher_profile
    elsif mentor?
      mentor_profile
    else
      false
    end
  end

  def create_record!
    ActiveRecord::Base.transaction do
      ParticipantDeclaration.create!(params.slice(*required_params)).tap do |participant_declaration|
        ProfileDeclaration.create!(
          participant_declaration: participant_declaration,
          declarable: user_profile,
        )
      end
    end
  end

  def lead_provider_from_token
    params[:lead_provider]
  end

  def actual_lead_provider
    SchoolCohort.find_by(school: school, cohort: cohort)&.lead_provider
  end

  def validate_provider!
    raise ActionController::ParameterMissing, I18n.t(:invalid_participant) unless actual_lead_provider.nil? || lead_provider_from_token == actual_lead_provider
  end

  def required_params
    (self.class.required_params - [:participant_id] + [:user_id])
  end
end
