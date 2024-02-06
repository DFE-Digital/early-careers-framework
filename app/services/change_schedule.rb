# frozen_string_literal: true

class ChangeSchedule
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :cpd_lead_provider
  attribute :participant_id
  attribute :course_identifier
  attribute :schedule_identifier
  attribute :cohort, :integer

  delegate :participant_profile_state, to: :participant_profile, allow_nil: true
  delegate :lead_provider, to: :cpd_lead_provider, allow_nil: true
  delegate :school, to: :relevant_induction_record, allow_nil: true

  validates :participant_id, participant_identity_presence: true
  validates :course_identifier, course: true, presence: { message: I18n.t(:missing_course_identifier) }
  validates :cpd_lead_provider, induction_record: true
  validates :schedule_identifier, presence: { message: I18n.t(:invalid_schedule) }
  validates :cohort, npq_contract_for_cohort_and_course: true
  validate :not_already_withdrawn
  validate :validate_new_schedule_valid_with_existing_declarations
  validate :change_with_a_different_schedule
  validate :validate_permitted_schedule_for_course
  validate :validate_cannot_change_cohort_ecf
  validate :validate_cannot_change_cohort_npq
  validate :validate_school_cohort_exists

  def call
    return if invalid?

    ActiveRecord::Base.transaction do
      ParticipantProfileSchedule.create!(participant_profile:, schedule: new_schedule)

      update_participant_profile_schedule_references!
    end

    participant_profile.record_to_serialize_for(lead_provider: cpd_lead_provider.lead_provider)
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

  def alias_search_query
    Finance::Schedule
      .where.not(identifier_alias: nil)
      .where(identifier_alias: schedule_identifier, cohort:)
  end

  def new_schedule
    @new_schedule ||= Finance::Schedule
      .where(schedule_identifier:, cohort:)
      .or(alias_search_query)
      .first
  end

  def schedule
    @schedule ||= participant_profile&.schedule_for(cpd_lead_provider:)
  end

  def cohort
    @cohort ||= super ? Cohort.find_by(start_year: super) : fallback_cohort
  end

private

  def user
    @user ||= participant_identity&.user
  end

  def fallback_cohort
    relevant_induction_record&.induction_programme&.school_cohort&.cohort.presence ||
      participant_profile&.schedule&.cohort.presence ||
      Cohort.current
  end

  def target_school_cohort
    @target_school_cohort ||= SchoolCohort.find_by(school:, cohort:)
  end

  def induction_programme
    @induction_programme ||=
      if school_partnership&.relationship
        relevant_induction_record&.induction_programme
      else
        target_school_cohort&.default_induction_programme
      end
  end

  def update_participant_profile_schedule_references!
    update_ecf_records!
    update_npq_records!

    true
  end

  def update_school_cohort_and_schedule!
    participant_profile.update!(school_cohort: target_school_cohort, schedule: new_schedule)
  end

  def update_induction_records!
    return unless relevant_induction_record

    Induction::ChangeInductionRecord.call(
      induction_record: relevant_induction_record,
      changes: {
        schedule: new_schedule,
        induction_programme:,
      },
    )
  end

  def update_ecf_records!
    return unless participant_profile&.ecf?

    update_school_cohort_and_schedule!
    update_induction_records!
    update_historical_induction_records!
  end

  def in_target?(induction_record)
    in_target_cohort?(induction_record) && in_target_schedule?(induction_record)
  end

  def in_target_cohort?(induction_record)
    induction_record.cohort_start_year == new_schedule.cohort_start_year
  end

  def in_target_schedule?(induction_record)
    induction_record.schedule == new_schedule
  end

  def historical_target_school_cohort(school)
    school.school_cohorts.for_year(new_schedule.cohort_start_year).first
  end

  def historical_school_cohort_partnership(historical_record)
    Partnership.create_with(relationship: true)
    .find_or_create_by!(school: historical_record.school,
                        cohort: new_schedule.cohort,
                        lead_provider: historical_record.lead_provider,
                        delivery_partner: historical_record.delivery_partner)
  end

  def historical_school_cohort_induction_programme(historical_record, partnership)
    school_cohort = historical_target_school_cohort(historical_record.school)

    InductionProgramme.full_induction_programme.find_or_create_by!(school_cohort:, partnership:)
  end

  def historical_induction_programme(historical_record)
    return historical_record.induction_programme if in_target_cohort?(historical_record)

    partnership = historical_school_cohort_partnership(historical_record)

    historical_school_cohort_induction_programme(historical_record, partnership)
  end

  def update_historical_induction_records!
    historical_records.all? do |historical_record|
      next true if in_target?(historical_record)

      begin
        historical_record.update!(induction_programme: historical_induction_programme(historical_record),
                                  schedule: new_schedule)
      rescue ActiveRecord::RecordInvalid
        false
      end
    end
  end

  def historical_records
    return [] unless participant_profile

    @historical_records ||= participant_profile.induction_records.order(created_at: :desc)
  end

  def update_schedule!
    participant_profile.update!(schedule: new_schedule)
  end

  def update_npq_application_cohort!
    return unless participant_profile.npq_application.cohort != new_schedule.cohort

    participant_profile.npq_application.update!(cohort: new_schedule.cohort)
  end

  def update_npq_records!
    return unless participant_profile&.npq?

    update_schedule!
    update_npq_application_cohort!
  end

  def relevant_induction_record
    return if user.blank? || participant_profile.blank?

    @relevant_induction_record ||= participant_profile.latest_induction_record_for(cpd_lead_provider:)
  end

  def not_already_withdrawn
    return unless participant_profile

    errors.add(:participant_id, I18n.t(:withdrawn_participant)) if participant_profile.withdrawn_for?(cpd_lead_provider:)
  end

  def validate_new_schedule_valid_with_existing_declarations
    return if user.blank? || participant_profile.blank?
    return unless new_schedule

    applicable_declarations.each do |declaration|
      milestone = new_schedule.milestones.find_by!(declaration_type: declaration.declaration_type)

      if declaration.declaration_date <= milestone.start_date.beginning_of_day
        errors.add(:schedule_identifier, I18n.t(:schedule_invalidates_declaration))
      end

      if milestone.milestone_date && (milestone.milestone_date.end_of_day < declaration.declaration_date)
        errors.add(:schedule_identifier, I18n.t(:schedule_invalidates_declaration))
      end
    end
  end

  def applicable_declarations
    @applicable_declarations ||= participant_profile.participant_declarations
      .where(state: %w[submitted eligible payable paid])
  end

  def validate_permitted_schedule_for_course
    return unless new_schedule

    unless new_schedule.class::PERMITTED_COURSE_IDENTIFIERS.include?(course_identifier)
      errors.add(:schedule_identifier, I18n.t(:schedule_invalid_for_course))
    end
  end

  def validate_cannot_change_cohort_ecf
    return unless participant_profile&.ecf?

    if applicable_declarations.any? &&
        relevant_induction_record &&
        relevant_induction_record.schedule.cohort.start_year != cohort&.start_year
      errors.add(:cohort, I18n.t("cannot_change_cohort"))
    end
  end

  def validate_cannot_change_cohort_npq
    return unless participant_profile&.npq? && new_schedule

    if applicable_declarations.any? && new_schedule.cohort.start_year != schedule.cohort.start_year
      errors.add(:cohort, I18n.t("cannot_change_cohort"))
    end
  end

  def change_with_a_different_schedule
    return unless new_schedule && participant_profile && new_schedule == participant_profile.schedule

    return if relevant_induction_record_has_different_schedule

    errors.add(:schedule_identifier, I18n.t(:schedule_already_on_the_profile))
  end

  def relevant_induction_record_has_different_schedule
    return unless relevant_induction_record

    new_schedule != relevant_induction_record.schedule
  end

  def validate_school_cohort_exists
    return unless participant_profile&.ecf?
    return if school_partnership.present?

    errors.add(:cohort, I18n.t(:missing_school_cohort_default_partnership))
  end

  def school_partnership
    return if school.blank?

    @school_partnership ||= school_partnership_without_relationship || school_partnership_including_relationship
  end

  def school_partnership_without_relationship
    school.active_partnerships.find_by(
      cohort:,
      lead_provider_id: cpd_lead_provider.lead_provider_id,
      relationship: false,
    )
  end

  def school_partnership_including_relationship
    return unless change_schedule_identifier_only?

    # We are assuming there is only ever one partnership record
    school.active_partnerships.find_by(
      cohort:,
      lead_provider_id: cpd_lead_provider.lead_provider_id,
    )
  end

  def change_schedule_identifier_only?
    cohort == schedule.cohort &&
      new_schedule != schedule
  end
end
