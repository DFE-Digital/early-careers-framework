# frozen_string_literal: true

module Participants
  module ChangeSchedule
    module ValidateAndChangeSchedule
      extend ActiveSupport::Concern
      include ActiveModel::Validations

      included do
        attr_accessor :schedule_identifier

        validates :schedule, presence: { message: I18n.t(:invalid_schedule) }
        validate :not_already_withdrawn
        validate :schedule_valid_with_pending_declarations
      end

      def perform_action!
        ActiveRecord::Base.transaction do
          ParticipantProfileSchedule.create!(participant_profile: user_profile, schedule_identifier: schedule.schedule_identifier)
          user_profile.update_schedule!(schedule)
        end
        user_profile
      end

    private

      def schedule
        Finance::Schedule.find_by(schedule_identifier: schedule_identifier)
      end

      def not_already_withdrawn
        errors.add(:participant_id, I18n.t(:withdrawn_participant)) if participant_profile_state&.withdrawn?
      end

      def schedule_valid_with_pending_declarations
        return unless user_profile

        declarations = user_profile.participant_declarations.not_voided
        declarations.each do |declaration|
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
