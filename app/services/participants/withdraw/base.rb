# frozen_string_literal: true

module Participants
  module Withdraw
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
        ParticipantProfileState.create!(participant_profile: user_profile, state: "withdrawn", reason: reason)
        user_profile
      end

    private

      attr_accessor :reason
      validates :reason, presence: true
      validate :not_already_withdrawn
      delegate :state, to: :not_implemented_error

      def initialize(params:)
        params.each do |param, value|
          send("#{param}=", value)
        end
      end

      def not_implemented_error
        self.class.not_implemented_error
      end

      def not_already_withdrawn
        return if errors.any?

        errors.add(:participant_id, I18n.t(:invalid_withdrawal)) if state&.withdrawn?
      end

      def validate_provider!
        return if errors.any?
        raise ActionController::ParameterMissing, [I18n.t(:invalid_participant)] unless matches_lead_provider?
      end
    end
  end
end
