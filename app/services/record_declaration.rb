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

  before_validation :declaration_attempt

  validates :declaration_date, :declaration_type, presence: true
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

  validate :validate_milestone_exists
  validate :validates_billable_slot_available
  validate :record_does_not_exists_with_different_declaration_date

  attr_reader :raw_declaration_date

  def call
    return if invalid?

    ParticipantDeclaration.transaction do
      set_eligibility

      unless participant_declaration.submitted?
        Finance::DeclarationStatementAttacher.new(participant_declaration).call
      end

      declaration_attempt.update!(participant_declaration:)
    end

    participant_declaration
  end

  def declaration_date=(raw_declaration_date)
    self.raw_declaration_date = raw_declaration_date
    super
  end

  def participant_identity
    @participant_identity ||= ParticipantIdentity.find_by(external_identifier: participant_id)
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
    if participant_id && cpd_lead_provider
      @declaration_attempt ||= ParticipantDeclarationAttempt.create!(
        course_identifier:,
        declaration_date:,
        declaration_type:,
        cpd_lead_provider:,
        user_id: participant_id,
      )
    end
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
    if milestone.blank?
      errors.add(:declaration_type, I18n.t(:mismatch_declaration_type_for_schedule))
    end
  end

  def participant_declaration
    @participant_declaration ||= participant_profile
                                   .participant_declarations
                                   .submitted
                                   .or(
                                     participant_profile
                                       .participant_declarations
                                       .billable,
                                   )
                                   .find_or_create_by!(declaration_parameters)
                                   .tap { |pd| pd.update!(uplift_flags) }
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
      user: participant_identity.user,
    }
  end

  def validate_evidence_held?
    return unless participant_profile

    declaration_type.present? && declaration_type != "started"
  end

  def original_participant_declaration
    @original_participant_declaration ||= participant_declaration.duplicate_declarations.order(created_at: :asc).first
  end

  def validates_billable_slot_available
    return unless participant_profile

    return unless participant_declaration_class_for(participant_profile)
                    .where(state: %w[submitted eligible payable paid])
                    .where(
                      user: participant_identity.user,
                      course_identifier:,
                      declaration_type:,
                    ).exists?

    errors.add(:base, I18n.t(:declaration_already_exists))
  end

  def participant_declaration_class_for(participant_profile)
    return ParticipantDeclaration::NPQ if participant_profile.is_a?(ParticipantProfile::NPQ)

    ParticipantDeclaration::ECF
  end

  def record_does_not_exists_with_different_declaration_date
    return unless participant_profile

    declaration = participant_profile
                    .participant_declarations
                    .not_voided
                    .find_by(
                      user: participant_identity.user,
                      course_identifier:,
                      declaration_type:,
                    )

    return unless declaration.present? && \
      (similar_declaration_for_same_lead_provider?(declaration) || same_declaration_for_a_different_lead_provider?(declaration))

    errors.add(
      :declaration_date,
      I18n.t(
        :declaration_with_another_date_already_exists,
        declaration_date: declaration.declaration_date.rfc3339,
      ),
    )
  end

  def similar_declaration_for_same_lead_provider?(declaration)
    declaration.declaration_date != declaration_date && declaration.cpd_lead_provider == cpd_lead_provider
  end

  def same_declaration_for_a_different_lead_provider?(declaration)
    declaration.cpd_lead_provider != cpd_lead_provider
  end
end
