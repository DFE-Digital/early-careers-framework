# frozen_string_literal: true

module Participants
  module ChangeSchedule
    class Base
      include ProfileAttributes
      include ActiveModel::Validations

      attr_reader :schedule_identifier, :cohort

      validates :schedule, presence: { message: I18n.t(:invalid_schedule) }
      validate :not_already_withdrawn
      validate :schedule_valid_with_pending_declarations
      validate :validate_provider

      def initialize(params:)
        @participant_id = params[:participant_id]
        @course_identifier = params[:course_identifier]
        @cpd_lead_provider = params[:cpd_lead_provider]
        @schedule_identifier = params[:schedule_identifier]
        @cohort = params[:cohort]
      end

      def call
        unless valid?
          raise ActionController::ParameterMissing, errors.map(&:message)
        end

        ActiveRecord::Base.transaction do
          ParticipantProfileSchedule.create!(participant_profile: user_profile, schedule: schedule)
          user_profile.update_schedule!(schedule)
        end

        user_profile
      end

    private

      def participant_profile_state
        user_profile&.participant_profile_state
      end

      def validate_provider
        unless matches_lead_provider?
          errors.add(:participant_id, I18n.t(:invalid_participant))
        end
      end

      def cohort_object
        @cohort_object ||= if @cohort
                             Cohort.find_by(start_year: @cohort)
                           else
                             Cohort.current
                           end
      end

      def schedule
        return @schedule if @schedule

        alias_search_query = Finance::Schedule
          .where("identifier_alias IS NOT NULL")
          .where(identifier_alias: schedule_identifier, cohort: cohort_object)

        @schedule = Finance::Schedule
          .where(schedule_identifier: schedule_identifier, cohort: cohort_object)
          .or(alias_search_query)
          .first
      end

      def not_already_withdrawn
        errors.add(:participant_id, I18n.t(:withdrawn_participant)) if participant_profile_state&.withdrawn?
      end

      def schedule_valid_with_pending_declarations
        user_profile&.participant_declarations&.each do |declaration|
          if declaration.changeable?
            milestone = schedule.milestones.find_by(declaration_type: declaration.declaration_type)
            if declaration.declaration_date <= milestone.start_date.beginning_of_day
              errors.add(:schedule_identifier, I18n.t(:schedule_invalidates_declaration))
            end

            if milestone.milestone_date.end_of_day < declaration.declaration_date
              errors.add(:schedule_identifier, I18n.t(:schedule_invalidates_declaration))
            end
          end
        end
      end
    end
  end
end
