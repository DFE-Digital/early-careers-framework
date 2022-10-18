# frozen_string_literal: true

class ChangeSchedule
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations::Callbacks
  include Participants::ProfileAttributes

  attribute :cpd_lead_provider
  attribute :participant_id
  attribute :reason
  attribute :course_identifier
  attribute :schedule_identifier
  attribute :cohort

  alias_attribute :user_profile, :participant_profile
  delegate :participant_profile_state, to: :participant_profile, allow_nil: true
  delegate :lead_provider, to: :cpd_lead_provider, allow_nil: true

  validates :schedule, presence: { message: I18n.t(:invalid_schedule) }
  validate :not_already_withdrawn
  validate :validate_new_schedule_valid_with_existing_declarations
  validate :validate_provider
  validate :validate_permitted_schedule_for_course
  validate :validate_cannot_change_cohort
  validate :schedule_valid_with_pending_declarations

  def call
    return if invalid?

    ActiveRecord::Base.transaction do
      ParticipantProfileSchedule.create!(participant_profile:, schedule:)
      participant_profile.update_schedule!(schedule)

      if relevant_induction_record
        Induction::ChangeInductionRecord.call(
          induction_record: relevant_induction_record,
          changes: {
            schedule:,
          },
        )
      end
    end

    relevant_induction_record_for_profile(participant_profile)
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
      .where("identifier_alias IS NOT NULL")
      .where(identifier_alias: schedule_identifier, cohort:)
  end

  def schedule
    @schedule ||= Finance::Schedule
      .where(schedule_identifier:, cohort:)
      .or(alias_search_query)
      .first
  end

  def valid_courses
    ValidCoursesResolver.call(
      course_identifier:,
    )
  end

private

  def cohort
    @cohort ||= if super
                  Cohort.find_by(start_year: super)
                else
                  Cohort.current
                end
  end

  def relevant_induction_record
    return if user.blank? || participant_profile.blank?

    participant_profile
      .induction_records
      .joins(induction_programme: { partnership: [:lead_provider] })
      .where(induction_programme: { partnerships: { lead_provider: } })
      .order(created_at: :asc)
      .last
  end

  def not_already_withdrawn
    if ParticipantProfile::ECF::COURSE_IDENTIFIERS.include?(course_identifier)
      errors.add(:participant_id, I18n.t(:withdrawn_participant)) if relevant_induction_record&.training_status_withdrawn?
    elsif ParticipantProfile::NPQ::COURSE_IDENTIFIERS.include?(course_identifier)
      errors.add(:participant_id, I18n.t(:withdrawn_participant)) if participant_profile_state&.withdrawn?
    end
  end

  def validate_new_schedule_valid_with_existing_declarations
    return if user.blank? || participant_profile.blank?
    return unless schedule

    participant_profile.participant_declarations.each do |declaration|
      next unless %w[submitted eligible payable paid].include?(declaration.state)

      milestone = schedule.milestones.find_by!(declaration_type: declaration.declaration_type)

      if declaration.declaration_date <= milestone.start_date.beginning_of_day
        errors.add(:schedule_identifier, I18n.t(:schedule_invalidates_declaration))
      end

      if milestone.milestone_date && (milestone.milestone_date.end_of_day < declaration.declaration_date)
        errors.add(:schedule_identifier, I18n.t(:schedule_invalidates_declaration))
      end
    end
  end

  def validate_provider
    return if user.blank? || participant_profile.blank?

    unless participant_profile && matches_lead_provider?
      errors.add(:participant_id, I18n.t(:invalid_participant))
    end
  end

  def matches_lead_provider?
    return unless course_identifier

    if ParticipantProfile::ECF::COURSE_IDENTIFIERS.include?(course_identifier)
      relevant_induction_record.present?
    elsif ParticipantProfile::NPQ::COURSE_IDENTIFIERS.include?(course_identifier)
      cpd_lead_provider == participant_profile&.npq_application&.npq_lead_provider&.cpd_lead_provider
    end
  end

  def validate_permitted_schedule_for_course
    return unless schedule

    unless schedule.class::PERMITTED_COURSE_IDENTIFIERS.include?(course_identifier)
      errors.add(:schedule_identifier, I18n.t(:schedule_invalid_for_course))
    end
  end

  def validate_cannot_change_cohort
    if relevant_induction_record &&
        relevant_induction_record.schedule.cohort.start_year != cohort&.start_year
      errors.add(:cohort, I18n.t("cannot_change_cohort"))
    end
  end

  def schedule_valid_with_pending_declarations
    return unless schedule

    participant_profile&.participant_declarations&.each do |declaration|
      if declaration.changeable?
        milestone = schedule.milestones.find_by(declaration_type: declaration.declaration_type)

        if declaration.declaration_date <= milestone.start_date.beginning_of_day
          errors.add(:schedule_identifier, I18n.t(:schedule_invalidates_declaration))
        end

        if milestone.milestone_date && (milestone.milestone_date.end_of_day < declaration.declaration_date)
          errors.add(:schedule_identifier, I18n.t(:schedule_invalidates_declaration))
        end
      end
    end
  end
end
