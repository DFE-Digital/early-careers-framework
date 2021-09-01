# frozen_string_literal: true

module Participants
  module ChangeSchedule
    class Base
      include ProfileAttributes

      class << self
        def call(params:)
          new(params: params).call
        end

        def not_implemented_error
          raise NotImplementedError, "Method must be implemented"
        end

        delegate :valid_courses, to: :not_implemented_error
      end

      def call
        unless valid?
          raise ActionController::ParameterMissing, errors.map(&:message)
        end

        validate_provider!
        validate_participant_state!
        user_profile.update_schedule!(schedule)
        user_profile
      end

    private

      attr_accessor :schedule_identifier
      validates :schedule, presence: { message: I18n.t(:invalid_schedule) }

      def initialize(params:)
        params.each do |param, value|
          send("#{param}=", value)
        end
      end

      def not_implemented_error
        self.class.not_implemented_error
      end

      def validate_provider!
        return if errors.any?
        raise ActionController::ParameterMissing, [I18n.t(:invalid_participant)] unless matches_lead_provider?
      end

      def validate_participant_state!
        return if errors.any?
        raise ActionController::ParameterMissing, [I18n.t(:invalid_participant)] if user_profile.state == "withdrawn"
      end

      def schedule
        Finance::Schedule.find_by(schedule_identifier: schedule_identifier)
      end
    end
  end
end
