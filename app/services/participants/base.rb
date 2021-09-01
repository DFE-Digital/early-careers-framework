# frozen_string_literal: true

module Participants
  class Base
    include ProfileAttributes

    class << self
      def call(params:)
        new(params: params).call
      end

      def not_implemented_error
        raise NotImplementedError, "Method must be implemented"
      end

      delegate :valid_courses, :state_to_transition_to, to: :not_implemented_error
    end

    def call
      unless valid?
        raise ActionController::ParameterMissing, errors.map(&:message)
      end

      business_validation!
      perform_action!
    end

    def business_validation!
      validate_provider!
    end

    def perform_action!
      ParticipantProfileState.create!(participant_profile: user_profile, state: self.class.state_to_transition_to, reason: reason)
      user_profile
    end

  private

    validate :not_already_withdrawn
    delegate :participant_profile_state, to: :not_implemented_error

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

      errors.add(:participant_id, I18n.t(:invalid_withdrawal)) if participant_profile_state&.withdrawn?
    end

    def validate_provider!
      return if errors.any?
      raise ActionController::ParameterMissing, [I18n.t(:invalid_participant)] unless matches_lead_provider?
    end
  end
end
