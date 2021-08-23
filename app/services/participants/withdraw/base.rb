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

        delegate :valid_courses_for_user, to: :not_implemented_error
      end

      def call
        unless valid?
          raise ActionController::ParameterMissing, errors.map(&:message)
        end

        validate_provider!
        ParticipantProfileState.create!(participant_profile: user_profile, state: "withdrawn", reason: reason)
      end

    private

      attr_accessor :reason
      validates :reason, presence: true
      validate :existing_profile
      validate :not_already_withdrawn
      delegate :present?, :state, to: :not_implemented_error

      def valid_courses_for_user
        self.class.valid_courses_for_user
      end

      def initialize(params:)
        params.each do |param, value|
          send("#{param}=", value)
        end
      end

      def not_implemented_error
        self.class.not_implemented_error
      end

      def not_already_withdrawn
        errors.add(:participant_id, I18n.t(:invalid_withdrawal)) if state&.withdrawn?
      end

      def validate_provider!
        errors.add(:participant_id, I18n.t(:invalid_participant)) unless matches_lead_provider?
      end
    end
  end
end
