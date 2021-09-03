# frozen_string_literal: true

module Participants
  module ChangeSchedule
    module ValidateAndChange
      extend ActiveSupport::Concern
      include ActiveModel::Validations

      included do
        attr_accessor :schedule_identifier
        validates :schedule, presence: { message: I18n.t(:invalid_schedule) }
        validate :not_already_withdrawn
      end

      def action!
        user_profile.update_schedule!(schedule)
        user_profile
      end

    private

      def schedule
        Finance::Schedule.find_by(schedule_identifier: schedule_identifier)
      end

      def not_already_withdrawn
        errors.add(:participant_id, I18n.t(:invalid_withdrawal)) if participant_profile_state&.withdrawn?
      end
    end
  end
end
