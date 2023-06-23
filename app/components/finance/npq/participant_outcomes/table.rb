# frozen_string_literal: true

module Finance
  module NPQ
    module ParticipantOutcomes
      class Table < BaseComponent
        attr_reader :participant_declaration

        delegate :outcomes, to: :participant_declaration

        def initialize(participant_declaration:)
          @participant_declaration = participant_declaration
        end

        def render?
          participant_declaration.participant_profile.npq? && outcomes.present?
        end

        def completion_date(outcome)
          outcome.completion_date.to_fs(:govuk)
        end

        def changed_date(outcome)
          outcome.created_at.to_fs(:govuk)
        end

        def sent_to_tra(outcome)
          outcome.sent_to_qualified_teachers_api_at&.to_fs(:govuk)
        end
      end
    end
  end
end
