# frozen_string_literal: true

module Finance
  module NPQ
    module ParticipantOutcomes
      class Table < BaseComponent
        attr_reader :participant_declaration

        def initialize(participant_declaration:)
          @participant_declaration = participant_declaration
        end

        def render?
          participant_declaration.participant_profile.npq? && outcomes.present?
        end

        def state(outcome)
          outcome.state&.capitalize
        end

        def completion_date(outcome)
          outcome.completion_date.to_fs(:govuk)
        end

        def changed_date(outcome)
          outcome.created_at.to_date.to_fs(:govuk)
        end

        def sent_to_tra_at(outcome)
          return t("finance.npq.participant_outcomes.na") if outcome.sent_to_qualified_teachers_api_at.blank?

          outcome.sent_to_qualified_teachers_api_at.to_date.to_fs(:govuk)
        end

        def sent_to_tra_tag(bool)
          if bool.nil?
            tag.strong(t("finance.npq.participant_outcomes.na"), class: "govuk-tag govuk-tag--yellow")
          elsif bool
            tag.strong(t("finance.npq.participant_outcomes.yes"), class: "govuk-tag govuk-tag--green")
          else
            tag.strong(t("finance.npq.participant_outcomes.no"), class: "govuk-tag govuk-tag--red")
          end
        end

        def caption_text
          title = t("finance.npq.participant_outcomes.declaration_outcomes")
          latest_outcome = outcomes.first

          return title if latest_outcome.blank?

          outcome_description = if latest_outcome.passed_but_not_sent?
                                  t("finance.npq.participant_outcomes.passed")
                                elsif latest_outcome.failed_but_not_sent?
                                  t("finance.npq.participant_outcomes.failed")
                                elsif latest_outcome.passed_and_recorded?
                                  t("finance.npq.participant_outcomes.passed_and_recorded")
                                elsif latest_outcome.failed_and_recorded?
                                  t("finance.npq.participant_outcomes.failed_and_recorded")
                                elsif latest_outcome.passed_but_not_recorded?
                                  t("finance.npq.participant_outcomes.passed_but_not_recorded")
                                elsif latest_outcome.failed_but_not_recorded?
                                  t("finance.npq.participant_outcomes.failed_but_not_recorded")
                                else
                                  latest_outcome.state.capitalize
                                end

          "#{title}: #{outcome_description}"
        end

      private

        def outcomes
          @outcomes ||= participant_declaration&.outcomes&.order(created_at: :desc)
        end
      end
    end
  end
end
