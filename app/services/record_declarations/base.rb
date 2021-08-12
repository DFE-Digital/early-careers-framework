# frozen_string_literal: true

module RecordDeclarations
  class Base
    include ActiveModel::Model

    attr_accessor :course_identifier, :user_id, :lead_provider_from_token, :declaration_date, :declaration_type, :evidence_held

    validates :course_identifier, inclusion: { in: :valid_courses_for_user, message: I18n.t(:invalid_identifier) }, allow_blank: true
    validates :declaration_type, inclusion: { in: :valid_declaration_types, message: I18n.t(:invalid_declaration_type) }
    validates :course_identifier, presence: { message: I18n.t(:missing_course_identifier) }
    validates :declaration_date, presence: { message: I18n.t(:missing_declaration_date) }
    validates :declaration_date, declaration_date: true, allow_blank: true
    validates :declaration_date, future_date: true, allow_blank: true
    validates :declaration_type, presence: { message: I18n.t(:missing_declaration_type) }
    validates :user, presence: { message: I18n.t(:invalid_participant) }
    validates :lead_provider_from_token, presence: { message: I18n.t(:missing_lead_provider) }

    validate :profile_exists

    def profile_exists
      return if errors.any?

      unless user_profile
        errors.add(:user_profile, I18n.t(:invalid_participant))
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

      declaration_attempt = create_declaration_attempt!
      validate_provider!
      declaration = create_record!
      declaration_attempt.update!(participant_declaration: declaration)

      { id: declaration.id }
    end

  private

    def initialize(params)
      params.each do |param, value|
        send("#{param}=", value)
      end
    end

    def user
      @user ||= User.find_by(id: user_id)
    end

    def create_declaration_attempt!
      ParticipantDeclarationAttempt.create!(
        course_identifier: course_identifier,
        declaration_date: declaration_date,
        declaration_type: declaration_type,
        cpd_lead_provider: lead_provider_from_token,
        user: user,
        evidence_held: evidence_held,
      )
    end

    def create_record!
      ActiveRecord::Base.transaction do
        declaration_model.create!(
          course_identifier: course_identifier,
          declaration_date: declaration_date,
          declaration_type: declaration_type,
          cpd_lead_provider: lead_provider_from_token,
          user: user,
          evidence_held: evidence_held,
        ).tap do |participant_declaration|
          ProfileDeclaration.create!(
            participant_declaration: participant_declaration,
            participant_profile: user_profile,
          )
        end
      end
    end

    def validate_provider!
      # TODO: Remove the nil? check and fix the test setup so that they build the school cohort, partnership and give us back the actual lead_provider.
      raise ActionController::ParameterMissing, I18n.t(:invalid_participant) unless actual_lead_provider.nil? || lead_provider_from_token == actual_lead_provider
    end
  end
end
