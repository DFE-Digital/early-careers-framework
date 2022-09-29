# frozen_string_literal: true

module Participants
  module ChangeSchedule
    class NPQ
      include ProfileAttributes
      include ActiveModel::Validations

      def self.valid_courses
        NPQCourse.identifiers
      end

      validates :schedule, presence: { message: I18n.t(:invalid_schedule) }
      validate :not_already_withdrawn
      validate :schedule_valid_with_pending_declarations
      validate :validate_provider
      validate :validate_permitted_schedule_for_course

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
        end

        user_profile
      end

    private

      attr_reader :schedule_identifier, :cohort_year

      def user_profile
        user
          .npq_profiles
          .active_record
          .includes({ npq_application: [:npq_course] })
          .where('npq_courses.identifier': course_identifier)
          .where({ npq_application: { npq_lead_provider: } })
          .first
      end

      def npq_lead_provider
        cpd_lead_provider.npq_lead_provider
      end

      def matches_lead_provider?
        cpd_lead_provider == user_profile&.npq_application&.npq_lead_provider&.cpd_lead_provider
      end

      def participant_profile_state
        user_profile&.participant_profile_state
      end

      def validate_provider
        unless matches_lead_provider?
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
        errors.add(:participant_id, I18n.t(:withdrawn_participant)) if participant_profile_state&.withdrawn?
      end

      def schedule_valid_with_pending_declarations
        return unless schedule

        user_profile&.participant_declarations&.each do |declaration|
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

      def validate_permitted_schedule_for_course
        return unless schedule

        unless schedule.class::PERMITTED_COURSE_IDENTIFIERS.include?(course_identifier)
          errors.add(:schedule_identifier, I18n.t(:schedule_invalid_for_course))
        end
      end
    end
  end
end
