# frozen_string_literal: true

require "abstract_interface"

module RecordDeclarations
  class Base
    include Participants::ProfileAttributes
    include AbstractInterface
    implement_class_method :required_params
    implement_instance_method :user_profile

    MultipleParticipantDeclarationDuplicate = Class.new(ArgumentError)

    RFC3339_DATE_REGEX = /\A\d{4}-\d{2}-\d{2}T(\d{2}):(\d{2}):(\d{2})([.,]\d+)?(Z|[+-](\d{2})(:?\d{2})?)?\z/i.freeze

    attr_accessor :declaration_date, :declaration_type

    validates :declaration_date, :declaration_type, presence: true
    validates :parsed_date, future_date: true, allow_blank: true
    validate :date_has_the_right_format
    validate :validate_schedule_present
    validate :validate_milestone_exists

    delegate :schedule, :participant_declarations, to: :user_profile, allow_nil: true

    class << self
      def call(params:)
        new(params: params).call
      end
    end

    def call
      unless valid?
        raise ActionController::ParameterMissing, errors.map(&:message)
      end

      declaration_attempt = create_declaration_attempt!
      validate_provider!
      validate_milestone!
      # validate_participant_state!

      raise ActiveRecord::RecordNotUnique, "Declaration with given participant ID already exists" if record_exists_with_different_declaration_date?

      ParticipantDeclaration.transaction do
        set_eligibility

        Finance::Statement.attach(participant_declaration) unless participant_declaration.submitted?
        declaration_attempt.update!(participant_declaration: participant_declaration)
      end

      Api::V1::ParticipantDeclarationSerializer.new(participant_declaration).serializable_hash.to_json
    end

    def initialize(params:)
      self.participant_id = params[:participant_id]
      self.course_identifier = params[:course_identifier]
      self.cpd_lead_provider = params[:cpd_lead_provider]
      self.declaration_date = params[:declaration_date]
      self.declaration_type = params[:declaration_type]
    end

  private

    def set_eligibility
      if participant_declaration.duplicate_declarations.any?
        participant_declaration.update!(superseded_by: original_participant_declaration)
        participant_declaration.make_ineligible!(reason: :duplicate)
      elsif user_profile.fundable?
        participant_declaration.make_eligible!
      end
    end

    def parsed_date
      Time.zone.parse(declaration_date)
    end

    def create_declaration_attempt!
      ParticipantDeclarationAttempt.create!(declaration_parameters.except(:participant_profile))
    end

    def participant_declaration
      @participant_declaration ||= self.class.declaration_model.create!(declaration_parameters)
    end

    def declaration_parameters
      {
        course_identifier: course_identifier,
        declaration_date: declaration_date,
        declaration_type: declaration_type,
        cpd_lead_provider: cpd_lead_provider,
        participant_profile: user_profile,
        user: user,
      }
    end

    def record_exists_with_different_declaration_date?
      declaration = self.class.declaration_model
                      .where.not(state: self.class.declaration_model.states[:voided])
                      .find_by(
                        user: user,
                        course_identifier: course_identifier,
                        declaration_type: declaration_type,
                      )

      declaration.present? && declaration.declaration_date != Time.zone.parse(declaration_date)
    end

    def date_has_the_right_format
      return if declaration_date.blank?

      errors.add(:declaration_date, I18n.t(:invalid_declaration_date)) unless declaration_date.match(RFC3339_DATE_REGEX)
      parsed_date
    rescue StandardError
      errors.add(:declaration_date, I18n.t(:invalid_declaration_date))
    end

    def validate_provider!
      raise ActionController::ParameterMissing, I18n.t(:invalid_participant) unless matches_lead_provider?
    end

    def validate_milestone!
      if parsed_date <= milestone.start_date.beginning_of_day
        raise ActionController::ParameterMissing, I18n.t(:declaration_before_milestone_start)
      end

      if milestone.milestone_date.present? && (milestone.milestone_date.end_of_day < parsed_date)
        raise ActionController::ParameterMissing, I18n.t(:declaration_after_milestone_cutoff)
      end
    end

    # def validate_participant_state!
    #   last_state = user_profile.state_at(declaration_date)
    #   raise ActionController::ParameterMissing, I18n.t(:declaration_on_incorrect_state) unless last_state&.state.nil? || last_state.active?
    # end

    def validate_schedule_present
      unless schedule
        errors.add(:schedule, I18n.t(:schedule_missing))
      end
    end

    def milestone
      schedule&.milestones&.find_by(declaration_type: declaration_type)
    end

    def validate_milestone_exists
      if milestone.blank?
        errors.add(:declaration_type, I18n.t(:mismatch_declaration_type_for_schedule))
      end
    end

    def original_participant_declaration
      @original_participant_declaration ||= participant_declaration.duplicate_declarations.order(created_at: :asc).first
    end
  end
end
