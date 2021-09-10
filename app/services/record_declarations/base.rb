# frozen_string_literal: true

require "abstract_interface"

module RecordDeclarations
  class Base
    include Participants::ProfileAttributes
    include AbstractInterface
    implement_class_method :required_params
    implement_instance_method :valid_declaration_types, :user_profile

    RFC3339_DATE_REGEX = /\A\d{4}-\d{2}-\d{2}T(\d{2}):(\d{2}):(\d{2})([\.,]\d+)?(Z|[+-](\d{2})(:?\d{2})?)?\z/i.freeze

    attr_accessor :declaration_date, :declaration_type
    validates :declaration_date, :declaration_type, presence: true
    validates :parsed_date, future_date: true, allow_blank: true
    validate :date_has_the_right_format

    validates :declaration_type, inclusion: { in: :valid_declaration_types, message: I18n.t(:invalid_declaration_type) }
    delegate :schedule, :participant_declarations, to: :user_profile, allow_nil: true

    class << self
      def call(params)
        new(params).call
      end
    end

    def call
      unless valid?
        raise ActionController::ParameterMissing, errors.map(&:message)
      end

      declaration_attempt = create_declaration_attempt!
      validate_provider!
      validate_milestone!

      raise ActiveRecord::RecordNotUnique, "Declaration with given participant ID already exists" if record_exists_with_different_declaration_date?

      declaration = find_or_create_record!

      declaration.refresh_payability!
      declaration_attempt.update!(participant_declaration: declaration)

      ParticipantDeclarationSerializer.new(declaration).serializable_hash.to_json
    end

  private

    def initialize(params)
      params.each do |param, value|
        send("#{param}=", value)
      end
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
      )
    end

    def find_or_create_record!
      ActiveRecord::Base.transaction do
        self.class.declaration_model.find_or_create_by!(
          course_identifier: course_identifier,
          declaration_date: declaration_date,
          declaration_type: declaration_type,
          cpd_lead_provider: cpd_lead_provider,
          user: user,
        ) do |participant_declaration|
          profile_declaration = ProfileDeclaration.create!(
            participant_declaration: participant_declaration,
            participant_profile: user_profile,
          )
          profile_declaration.update!(payable: participant_declaration.currently_payable)
        end
      end
    end

    def record_exists_with_different_declaration_date?
      declaration = self.class.declaration_model.find_by(
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

    def valid_declaration_types
      self.class.valid_declaration_types
    end
  end
end
