# frozen_string_literal: true

module RecordDeclarations
  class Base
    include ActiveModel::Model

    attr_accessor :course_identifier, :user, :cpd_lead_provider, :declaration_date, :declaration_type, :evidence_held
    attr_accessor :params

    validates :course_identifier, inclusion: { in: :valid_courses_for_user, message: "The property '#/course_identifier' must be an available course to '#/participant_id'" }
    validates :declaration_type, inclusion: { in: :valid_declaration_types, message: "The property '#/declaration_type' must be an available for course_identifier '#/course_identifier'" }
    validates :course_identifier, presence: { message: "The property '#/course_identifier' must be present" }
    validates :declaration_date, presence: { message: "The property '#/declaration_date' must be present" }
    validates :declaration_type, presence: { message: "The property '#/declaration_type' must be present" }
    validates :user, presence: { message: "The participant must be exist" }
    validates :cpd_lead_provider, presence: { message: "The lead provider must be present" }
    validate :profile_exists

    def profile_exists
      return if errors.any?

      unless user_profile
        errors.add(:user_profile, "User profile must exist")
      end
    end

    def valid_courses_for_user
      valid_courses = []
      valid_courses << "ecf-mentor" if user.mentor?
      valid_courses << "ecf-induction" if user.early_career_teacher?
      valid_courses += NPQCourse.all.map(&:identifier) if user.npq?
      valid_courses
    end

    delegate :user_profile, :actual_lead_provider, :valid_declaration_types, to: :not_implemented_error

    class << self
      delegate :required_params, to: :not_implemented_error

      def call(params)
        new(params).call
      end

      def not_implemented_error
        raise NotImplementedError, "Method must be implemented"
      end
    end

    def not_implemented_error
      self.class.not_implemented_error
    end

    def call
      unless valid?
        raise ActionController::ParameterMissing, errors.map(&:message)
      end

      declaration = create_record!
      validate_provider!
      { id: declaration.id }
    end

  private

    def initialize(params)
      @params = params
      @course_identifier = params[:course_identifier]
      @declaration_date = params[:declaration_date]
      @declaration_type = params[:declaration_type]
      @cpd_lead_provider = params[:lead_provider_from_token]
      @evidence_held = params[:evidence_held]
      @user = User.find_by(id: params[:user_id])
    end

    def create_record!
      ActiveRecord::Base.transaction do
        declaration_model.create!(
          course_identifier: course_identifier,
          declaration_date: declaration_date,
          declaration_type: declaration_type,
          cpd_lead_provider: cpd_lead_provider,
          user: user,
          evidence_held: evidence_held,
          raw_event: params[:raw_event],
        ).tap do |participant_declaration|
          ProfileDeclaration.create!(
            participant_declaration: participant_declaration,
            participant_profile: user_profile,
          )
        end
      end
    end

    def lead_provider_from_token
      params[:lead_provider_from_token]
    end

    def validate_provider!
      # TODO: Remove the nil? check and fix the test setup so that they build the school cohort, partnership and give us back the actual lead_provider.
      raise ActionController::ParameterMissing, I18n.t(:invalid_participant) unless actual_lead_provider.nil? || lead_provider_from_token == actual_lead_provider
    end
  end
end
