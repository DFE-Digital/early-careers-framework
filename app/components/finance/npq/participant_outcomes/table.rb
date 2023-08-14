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
          return "<strong class='govuk-tag govuk-tag--yellow'>#{t('finance.npq.participant_outcomes.na')}</strong>".html_safe if outcome.sent_to_qualified_teachers_api_at.blank?

          outcome.sent_to_qualified_teachers_api_at.to_date.to_fs(:govuk)
        end

        def sent_to_tra_tag(bool)
          if bool.nil?
            "<strong class='govuk-tag govuk-tag--yellow'>#{t('finance.npq.participant_outcomes.na')}</strong>"
          elsif bool
            "<strong class='govuk-tag govuk-tag--green'>#{t('finance.npq.participant_outcomes.yes')}</strong>"
          else
            "<strong class='govuk-tag govuk-tag--red'>#{t('finance.npq.participant_outcomes.no')}</strong>"
          end.html_safe
        end

        def caption_text
          titles = [t("finance.npq.participant_outcomes.declaration_outcomes")]

          latest_outcome = outcomes.first

          return titles.join if latest_outcome.blank?

          if latest_outcome.passed_and_not_sent?
            titles << t("finance.npq.participant_outcomes.passed")
          elsif latest_outcome.failed_and_not_sent?
            titles << t("finance.npq.participant_outcomes.failed")
          elsif latest_outcome.passed_and_recorded?
            titles << t("finance.npq.participant_outcomes.passed_and_recorded")
          elsif latest_outcome.failed_and_recorded?
            titles << t("finance.npq.participant_outcomes.failed_and_recorded")
          elsif latest_outcome.passed_and_not_recorded?
            titles << t("finance.npq.participant_outcomes.passed_and_not_recorded")
          elsif latest_outcome.failed_and_not_recorded?
            titles << t("finance.npq.participant_outcomes.failed_and_not_recorded")
          end

          titles.join(": ")
        end

      private

        def outcomes
          @outcomes ||= participant_declaration&.outcomes&.order(created_at: :desc)
        end
      end
    end
  end
end
