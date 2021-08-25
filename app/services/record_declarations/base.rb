# frozen_string_literal: true

module RecordDeclarations
  class Base
    include ActiveModel::Model
    RFC3339_DATE_REGEX = /\A\d{4}-\d{2}-\d{2}T(\d{2}):(\d{2}):(\d{2})([\.,]\d+)?(Z|[+-](\d{2})(:?\d{2})?)?\z/i.freeze

    attr_accessor :course_identifier, :participant_id, :cpd_lead_provider, :declaration_date, :declaration_type, :evidence_held

    validates :course_identifier, inclusion: { in: :valid_courses_for_user, message: I18n.t(:invalid_identifier) }, allow_blank: true
    validates :declaration_type, inclusion: { in: :valid_declaration_types, message: I18n.t(:invalid_declaration_type) }
    validates :course_identifier, presence: { message: I18n.t(:missing_course_identifier) }
    validates :declaration_date, presence: { message: I18n.t(:missing_declaration_date) }
    validates :declaration_type, presence: { message: I18n.t(:missing_declaration_type) }
    validates :user, presence: { message: I18n.t(:invalid_participant) }
    validates :cpd_lead_provider, presence: { message: I18n.t(:missing_lead_provider) }
    validates :parsed_date, future_date: true, allow_blank: true

    validate :profile_exists
    validate :date_has_the_right_format

    delegate :user_profile, :actual_lead_provider, :valid_declaration_types, to: :not_implemented_error
    delegate :schedule, :participant_declarations, to: :user_profile

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
      validate_milestone!
      declaration = create_record!
      declaration.refresh_payability!
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
      @user ||= User.find_by(id: participant_id)
    end

    def parsed_date
      Time.zone.parse(declaration_date)
    end

    def create_declaration_attempt!
      ParticipantDeclarationAttempt.create!(
        course_identifier: course_identifier,
        declaration_date: declaration_date,
        declaration_type: declaration_type,
        cpd_lead_provider: cpd_lead_provider,
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
          cpd_lead_provider: cpd_lead_provider,
          user: user,
          evidence_held: evidence_held,
        ).tap do |participant_declaration|
          profile_declaration = ProfileDeclaration.create!(
            participant_declaration: participant_declaration,
            participant_profile: user_profile,
          )
          profile_declaration.update!(payable: participant_declaration.currently_payable)
        end
      end
    end

    def valid_courses_for_user
      self.class.valid_courses_for_user
    end

    def profile_exists
      return if errors.any?

      errors.add(:participant_id, I18n.t(:invalid_participant)) if user.participant_profiles.blank?
      errors.add(:participant_id, I18n.t(:invalid_course)) unless user_profile
    end

    def date_has_the_right_format
      return if declaration_date.blank?

      errors.add(:declaration_date, I18n.t(:invalid_declaration_date)) unless declaration_date.match(RFC3339_DATE_REGEX)
      parsed_date
    rescue StandardError
      errors.add(:declaration_date, I18n.t(:invalid_declaration_date))
    end

    def validate_provider!
      raise ActionController::ParameterMissing, I18n.t(:invalid_participant) unless cpd_lead_provider == actual_lead_provider
    end

    def validate_milestone!
      unless milestone.start_date.beginning_of_day < parsed_date
        raise ActionController::ParameterMissing, I18n.t(:declaration_before_milestone_start)
      end

      unless parsed_date <= milestone.milestone_date.end_of_day
        raise ActionController::ParameterMissing, I18n.t(:declaration_after_milestone_cutoff)
      end
    end

    def milestone
      unless schedule
        raise ActionController::ParameterMissing, I18n.t(:schedule_missing)
      end

      declaration_to_milestone_map[declaration_type]
    end

    def declaration_to_milestone_map
      {
        "started" => schedule.milestones[0],
        "retained-1" => schedule.milestones[1],
        "retained-2" => schedule.milestones[2],
        "retained-3" => schedule.milestones[3],
        "retained-4" => schedule.milestones[4],
        "completed" => schedule.milestones.last,
      }
    end
  end
end
