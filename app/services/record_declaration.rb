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

  before_validation :ensure_npq_course_no_longer_supported
  before_validation :declaration_attempt

  validates :participant_id, participant_identity_presence: true, participant_not_withdrawn: true
  validates :declaration_date, presence: { message: I18n.t(:missing_declaration_date) }
  validates :declaration_type, presence: { message: I18n.t(:missing_declaration_type) }
  validates :declaration_date, future_date: true, declaration_date: true, allow_blank: true
  validate :output_fee_statement_available
  validate :validate_milestone_exists
  validate :validates_billable_slot_available
  validate :validate_only_started_or_completed_if_mentor
  validates :course_identifier, course: true
  validates :cpd_lead_provider, induction_record: true
  validates :evidence_held, evidence_held: true

  attr_reader :raw_declaration_date

  def call
    return if invalid?

    ParticipantDeclaration.transaction do
      set_eligibility

      unless participant_declaration.submitted?
        Finance::DeclarationStatementAttacher.new(participant_declaration).call
      end

      declaration_attempt.update!(participant_declaration:)

      check_mentor_completion
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
                                )
  end

  def participant_profile
    @participant_profile ||= ParticipantProfileResolver
                               .call(
                                 participant_identity:,
                                 course_identifier:,
                               )
  end

  def milestone
    return unless schedule

    schedule.milestones.find_by(declaration_type:)
  end

  def relevant_induction_record
    @relevant_induction_record ||= Induction::FindBy.call(
      participant_profile:,
      lead_provider: cpd_lead_provider.lead_provider,
      date_range: ..declaration_date,
    )
  end

private

  attr_writer :raw_declaration_date

  delegate :schedule, to: :participant_profile, allow_nil: true
  delegate :cohort, to: :schedule

  def participant_profile_for_course_identifier
    nil unless participant_identity
  end

  def output_fee_statement_available
    return if participant_profile.blank?
    return if existing_declaration&.submitted?
    return if existing_declaration.nil? && !participant_profile.fundable?

    next_output_fee_statement = cpd_lead_provider.lead_provider.next_output_fee_statement(cohort)

    errors.add(:cohort, I18n.t(:no_output_fee_statements_for_cohort, cohort: cohort.start_year)) if next_output_fee_statement.blank?
  end

  def declaration_attempt
    if user && cpd_lead_provider
      @declaration_attempt ||= ParticipantDeclarationAttempt.create!(
        course_identifier:,
        declaration_date:,
        declaration_type:,
        cpd_lead_provider:,
        user:,
        evidence_held:,
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
    @participant_declaration ||= find_participant_declaration.tap do |pd|
      pd.update!(uplift_flags)
    end
  end

  def find_participant_declaration
    existing_declaration || participant_profile.participant_declarations.create!(declaration_parameters.merge(cohort:))
  end

  def existing_declaration
    @existing_declaration ||= participant_profile
      .participant_declarations
      .submitted
      .or(
        participant_profile
          .participant_declarations
          .billable,
      )
      .find_by(declaration_parameters)
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
      mentor_user_id:,
      user: participant_identity.user,
      evidence_held:,
    }
  end

  def mentor_user_id
    return nil unless participant_profile.ect?

    relevant_induction_record&.mentor_profile&.participant_identity&.user_id
  end

  def delivery_partner
    relevant_induction_record&.induction_programme&.partnership&.delivery_partner
  end

  def original_participant_declaration
    @original_participant_declaration ||= participant_declaration.duplicate_declarations.order(created_at: :asc).first
  end

  def validate_only_started_or_completed_if_mentor
    return if declaration_type&.in?(%w[started completed])
    return unless participant_profile && participant_profile.mentor?
    return unless cohort && cohort.mentor_funding?

    errors.add(:declaration_type, I18n.t(:retained_declaration_not_allowed_for_mentor))
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
    if participant_profile.mentor?
      ParticipantDeclaration::Mentor
    else
      ParticipantDeclaration::ECT
    end
  end

  def check_mentor_completion
    ParticipantDeclarations::HandleMentorCompletion.call(participant_declaration:)
  end

  def ensure_npq_course_no_longer_supported
    if course_identifier.to_s.starts_with?("npq-")
      errors.add(:course_identifier, I18n.t(:npq_course_no_longer_supported))
      throw(:abort)
    end
  end
end
