# frozen_string_literal: true

module Api
  module V3
    class NPQApplicationSerializer < V1::NPQApplicationSerializer
      attribute(:schedule_identifier, if: -> { FeatureFlag.active?(:accept_npq_application_can_change_schedule) }) do |object|
        object.profile&.schedule&.schedule_identifier
      end
    end
  end
end
