# frozen_string_literal: true

require "abstract_interface"

module Participants
  class Base
    include ActiveModel::Validations
    include ProfileAttributes
    include AbstractInterface
    implement_class_method :valid_courses

    class << self
      def call(params:)
        new(params: params).call
      end
    end

    def call
      unless valid?
        raise ActionController::ParameterMissing, errors.map(&:message)
      end

      validate_provider!
      perform_action!
    end

  private

    implement_instance_method :participant_profile_state, :participant_profile_states, :perform_action!, :matches_lead_provider?

    def initialize(params:)
      params.each do |param, value|
        send("#{param}=", value)
      end
    end

    def validate_provider!
      return if errors.any?
      raise ActionController::ParameterMissing, [I18n.t(:invalid_participant)] unless matches_lead_provider?
    end
  end
end
