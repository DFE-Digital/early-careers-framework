# frozen_string_literal: true

class ChangeSchedule
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations::Callbacks

  attribute :cpd_lead_provider
  attribute :participant_id
  attribute :course_identifier
  attribute :schedule_identifier
  attribute :cohort

  delegate :participant_profile_state, to: :participant_profile, allow_nil: true
  delegate :lead_provider, to: :cpd_lead_provider, allow_nil: true

  validates :course_identifier, course: true, presence: { message: I18n.t(:missing_course_identifier) }
  validates :cpd_lead_provider, induction_record: true
  validates :schedule_identifier, presence: { message: I18n.t(:invalid_schedule) }
  validate :not_already_withdrawn
  validate :validate_new_schedule_valid_with_existing_declarations
  validate :validate_permitted_schedule_for_course
  validate :validate_cannot_change_cohort

  def call
    return if invalid?

    ActiveRecord::Base.transaction do
      ParticipantProfileSchedule.create!(participant_profile:, schedule: new_schedule)
      participant_profile.update_schedule!(new_schedule)

      if relevant_induction_record
        Induction::ChangeInductionRecord.call(
          induction_record: relevant_induction_record,
          changes: {
            schedule: new_schedule,
          },
        )
      end
    end

    participant_profile.record_to_serialize_for(lead_provider: cpd_lead_provider.lead_provider)
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

private

  def user
    @user ||= participant_identity&.user
  end

  def cohort
    @cohort ||= if super
                  Cohort.find_by(start_year: super)
                else
                  Cohort.current
                end
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

    participant_profile.participant_declarations.each do |declaration|
      next unless %w[submitted eligible payable paid].include?(declaration.state)

      milestone = new_schedule.milestones.find_by!(declaration_type: declaration.declaration_type)

      if declaration.declaration_date <= milestone.start_date.beginning_of_day
        errors.add(:schedule_identifier, I18n.t(:schedule_invalidates_declaration))
      end

      if milestone.milestone_date && (milestone.milestone_date.end_of_day < declaration.declaration_date)
        errors.add(:schedule_identifier, I18n.t(:schedule_invalidates_declaration))
      end
    end
  end

  def validate_permitted_schedule_for_course
    return unless new_schedule

    unless new_schedule.class::PERMITTED_COURSE_IDENTIFIERS.include?(course_identifier)
      errors.add(:schedule_identifier, I18n.t(:schedule_invalid_for_course))
    end
  end

  def validate_cannot_change_cohort
    if relevant_induction_record &&
        relevant_induction_record.schedule.cohort.start_year != cohort&.start_year
      errors.add(:cohort, I18n.t("cannot_change_cohort"))
    end
  end
end
