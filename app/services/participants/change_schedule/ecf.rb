# frozen_string_literal: true

module Participants
  module ChangeSchedule
    class ECF
      include ActiveModel::Validations

      attr_accessor :course_identifier, :participant_id, :cpd_lead_provider

      delegate :school_cohort, to: :user_profile, allow_nil: true

      validates :course_identifier, course: true, presence: { message: I18n.t(:missing_course_identifier) }
      validates :participant_id, presence: { message: I18n.t(:missing_participant_id) }
      validates :cpd_lead_provider, presence: { message: I18n.t(:missing_cpd_lead_provider) }
      validates :schedule, presence: { message: I18n.t(:invalid_schedule) }

      validates :participant_id, format: /\A[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}\Z/, allow_blank: true

      validate :validate_participant_identity_found

      validate :participant_has_user_profile
      validate :course_valid_for_participant

      validate :not_already_withdrawn
      validate :validate_new_schedule_valid_with_existing_declarations
      validate :validate_provider
      validate :validate_permitted_schedule_for_course

      validate :validate_cannot_change_cohort

      def initialize(params:)
        @participant_id = params[:participant_id]
        @course_identifier = params[:course_identifier]
        @cpd_lead_provider = params[:cpd_lead_provider]
        @schedule_identifier = params[:schedule_identifier]
        @cohort_year = params[:cohort]
      end

      def call
        unless valid?
          raise ActionController::ParameterMissing, errors.map(&:message)
        end

        ActiveRecord::Base.transaction do
          ParticipantProfileSchedule.create!(participant_profile: user_profile, schedule:)
          user_profile.update_schedule!(schedule)

          if relevant_induction_record
            Induction::ChangeInductionRecord.call(
              induction_record: relevant_induction_record,
              changes: {
                schedule:,
              },
            )
          end
        end

        user_profile
      end

      def participant_identity
        @participant_identity ||= ParticipantIdentity.find_by(external_identifier: participant_id)
      end

    private

      def validate_cannot_change_cohort
        if relevant_induction_record &&
            relevant_induction_record.schedule.cohort.start_year != cohort&.start_year
          errors.add(:cohort, I18n.t("cannot_change_cohort"))
        end
      end

      def participant_has_user_profile
        errors.add(:participant_id, I18n.t(:invalid_participant)) if user && user_profile.blank?
      end

      def user
        @user ||= participant_identity&.user
      end

      attr_reader :schedule_identifier, :cohort_year

      def course_valid_for_participant
        valid_courses
      end

      def valid_courses
        case course_identifier
        when "ecf-induction"
          %w[ecf-induction]
        when "ecf-mentor"
          %w[ecf-mentor]
        else
          errors.add(:course_identifier, I18n.t(:invalid_identifier))
        end
      end

      def user_profile
        case course_identifier
        when "ecf-induction"
          user&.early_career_teacher_profile
        when "ecf-mentor"
          user&.mentor_profile
        end
      end

      def relevant_induction_record
        return if user.blank? || user_profile.blank?

        user_profile
          .induction_records
          .joins(induction_programme: { partnership: [:lead_provider] })
          .where(induction_programme: { partnerships: { lead_provider: } })
          .order(created_at: :asc)
          .last
      end

      def lead_provider
        cpd_lead_provider.lead_provider
      end

      def participant_profile_state
        user_profile&.participant_profile_state
      end

      def validate_provider
        return if user.blank? || user_profile.blank?

        unless user_profile && matches_lead_provider?
          errors.add(:participant_id, I18n.t(:invalid_participant))
        end
      end

      def cohort
        @cohort ||= if cohort_year
                      Cohort.find_by(start_year: cohort_year)
                    else
                      Cohort.current
                    end
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

      def not_already_withdrawn
        errors.add(:participant_id, I18n.t(:withdrawn_participant)) if relevant_induction_record&.training_status_withdrawn?
      end

      def validate_new_schedule_valid_with_existing_declarations
        return if user.blank? || user_profile.blank?
        return unless schedule

        user_profile.participant_declarations.each do |declaration|
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

      def validate_permitted_schedule_for_course
        return unless schedule

        unless schedule.class::PERMITTED_COURSE_IDENTIFIERS.include?(course_identifier)
          errors.add(:schedule_identifier, I18n.t(:schedule_invalid_for_course))
        end
      end

      def matches_lead_provider?
        relevant_induction_record.present?
      end

      def validate_participant_identity_found
        errors.add(:participant_id, I18n.t(:invalid_participant)) if participant_identity.blank?
      end
    end
  end
end
