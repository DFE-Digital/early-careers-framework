# frozen_string_literal: true

class RecordDeclaration
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations::Callbacks

  attribute :course_identifier
  attribute :cpd_lead_provider
  attribute :declaration_date, :datetime
  attribute :declaration_type
  attribute :participant_id
  attribute :evidence_held
  attribute :has_passed

  before_validation :declaration_attempt

  validates :declaration_date, presence: { message: I18n.t(:missing_declaration_date) }
  validates :declaration_type, presence: { message: I18n.t(:missing_declaration_type) }
  validates :declaration_date, future_date: true, declaration_date: true, allow_blank: true
  validates :participant_id, participant_not_withdrawn: true
  validates :cpd_lead_provider, induction_record: true
  validates :course_identifier, course: true
  validates :evidence_held,
            presence: { message: I18n.t(:missing_evidence_held), if: :validate_evidence_held? },
            inclusion: {
              in: ->(record_declaration) { record_declaration.participant_profile.class::VALID_EVIDENCE_HELD },
              if: :validate_evidence_held?,
              message: I18n.t(:invalid_evidence_type),
            }
  validate :validate_has_passed_field, if: :validate_has_passed?
  validate :validate_milestone_exists
  validate :validates_billable_slot_available

  attr_reader :raw_declaration_date

  def call
    return if invalid?

    ParticipantDeclaration.transaction do
      set_eligibility

      unless participant_declaration.submitted?
        Finance::DeclarationStatementAttacher.new(participant_declaration).call
      end

      declaration_attempt.update!(participant_declaration:)

      create_participant_outcome
    end

    participant_declaration
  end

  def declaration_date=(raw_declaration_date)
    self.raw_declaration_date = raw_declaration_date
    super
  end

  def participant_identity
    @participant_identity ||= ParticipantIdentityResolver
                                .call(
                                  participant_id:,
                                  course_identifier:,
                                  cpd_lead_provider:,
                                )
  end

  def participant_profile
    @participant_profile ||= ParticipantProfileResolver
                               .call(
                                 participant_identity:,
                                 course_identifier:,
                                 cpd_lead_provider:,
                               )
  end

  def milestone
    return unless schedule

    schedule.milestones.find_by(declaration_type:)
  end

  def schedule
    participant_profile&.schedule
  end

private

  attr_writer :raw_declaration_date

  def participant_profile_for_course_identifier
    return unless participant_identity
  end

  def declaration_attempt
    if user && cpd_lead_provider
      @declaration_attempt ||= ParticipantDeclarationAttempt.create!(
        course_identifier:,
        declaration_date:,
        declaration_type:,
        cpd_lead_provider:,
        user:,
      )
    end
  end

  def user
    @user ||= participant_identity&.user
  end

  def set_eligibility
    if participant_declaration.duplicate_declarations.any?
      participant_declaration.update!(superseded_by: original_participant_declaration)
      participant_declaration.make_ineligible!(reason: :duplicate)
    elsif participant_profile.fundable?
      participant_declaration.make_eligible!
    end
  end

  def validate_milestone_exists
    return unless participant_profile

    if milestone.blank?
      errors.add(:declaration_type, I18n.t(:mismatch_declaration_type_for_schedule))
    end
  end

  def participant_declaration
    @participant_declaration ||= find_participant_declaration.tap { |pd| pd.update!(uplift_flags) }
  end

  def find_participant_declaration
    participant_profile
      .participant_declarations
      .submitted
      .or(
        participant_profile
          .participant_declarations
          .billable,
      )
      .create_or_find_by!(declaration_parameters)
  end

  def uplift_flags
    {
      pupil_premium_uplift: participant_profile.pupil_premium_uplift,
      sparsity_uplift: participant_profile.sparsity_uplift,
    }
  end

  def declaration_parameters
    {
      course_identifier:,
      declaration_date:,
      declaration_type:,
      cpd_lead_provider:,
      delivery_partner:,
      user: participant_identity.user,
    }
  end

  def delivery_partner
    Induction::FindBy.call(participant_profile:, lead_provider: cpd_lead_provider.lead_provider)
      &.induction_programme
      &.partnership
      &.delivery_partner
  end

  def validate_evidence_held?
    return unless participant_profile && participant_profile.is_a?(ParticipantProfile::ECF)

    declaration_type.present? && declaration_type != "started"
  end

  def original_participant_declaration
    @original_participant_declaration ||= participant_declaration.duplicate_declarations.order(created_at: :asc).first
  end

  def validates_billable_slot_available
    return unless participant_profile

    return unless participant_declaration_class
                    .where(state: %w[submitted eligible payable paid])
                    .where(
                      user: participant_identity.user,
                      course_identifier:,
                      declaration_type:,
                    ).exists?

    errors.add(:base, I18n.t(:declaration_already_exists))
  end

  def participant_declaration_class
    if participant_profile.npq?
      ParticipantDeclaration::NPQ
    else
      ParticipantDeclaration::ECF
    end
  end

  def validate_has_passed_field
    self.has_passed = has_passed.to_s

    if has_passed.blank?
      errors.add(:has_passed, I18n.t(:missing_has_passed))
    elsif !%w[true false].include?(has_passed)
      errors.add(:has_passed, I18n.t(:invalid_has_passed))
    end
  end

  def validate_has_passed?
    return false unless valid_course_identifier_for_participant_outcome?

    participant_profile&.npq? &&
      declaration_type == "completed"
  end

  def valid_course_identifier_for_participant_outcome?
    !(
      ::Finance::Schedule::NPQEhco::IDENTIFIERS +
      ::Finance::Schedule::NPQSupport::IDENTIFIERS
    ).compact.include?(course_identifier)
  end

  def participant_outcome_state
    has_passed.to_s == "true" ? "passed" : "failed"
  end

  def create_participant_outcome
    return unless validate_has_passed?

    NPQ::CreateParticipantOutcome.new(
      cpd_lead_provider:,
      course_identifier:,
      participant_external_id: participant_identity.user_id,
      completion_date: declaration_date,
      state: participant_outcome_state,
    ).call
  end
end
