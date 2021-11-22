# frozen_string_literal: true

module Finance
  module NPQ
    class ParticipantEligibleAndPayableAggregator < Finance::ParticipantAggregator
      class << self
        def call(cpd_lead_provider:, course_identifier:, interval:, recorder: ParticipantDeclaration::NPQ, event_type: :started)
          new(cpd_lead_provider: cpd_lead_provider, recorder: recorder, course_identifier: course_identifier)
            .call(event_type: event_type, interval: interval)
        end

        def aggregation_types
          {
            started: {
              all: :neither_paid_nor_voided_lead_provider_and_course,
              eligible_or_payable: :eligible_or_payable_for_lead_provider_and_course,
              not_paid: :submitted_for_lead_provider_and_course,
            },
          }
        end
      end

    private

      attr_accessor :cpd_lead_provider, :recorder, :course_identifier

      def initialize(cpd_lead_provider:, course_identifier:, recorder: ParticipantDeclaration::NPQ)
        self.cpd_lead_provider = cpd_lead_provider
        self.recorder          = recorder
        self.course_identifier = course_identifier
      end

      def aggregate(aggregation_type:, event_type:, interval:)
        scope = recorder.public_send(self.class.aggregation_types[event_type][aggregation_type], cpd_lead_provider, course_identifier)
        scope = scope.submitted_between(interval.begin, interval.end) if interval.present?
        scope.count
      end

      # def initialize(cpd_lead_provider:, course_identifier:)
      #   self.cpd_lead_provider       = cpd_lead_provider
      #   self.course_identifier       = course_identifier
      # end

      # def current_participants_count(interval)
      #   ParticipantDeclaration::NPQ
      #     .submitted_between(interval.begin, interval.end)
      #     .for_lead_provider_and_course(cpd_lead_provider, course_identifier)
      #     .where.not(state: ParticipantDeclaration.states.values_at("paid", "voided"))
      #     .unique_id
      #     .count
      # end

      # def total_participant_eligible_and_payable_count(interval)
      #   ParticipantDeclaration::NPQ
      #     .submitted_between(interval.begin, interval.end)
      #     .for_lead_provider_and_course(cpd_lead_provider, course_identifier)
      #     .eligible_or_payable
      #     .unique_id
      #     .count
      # end

      # def total_participant_not_paid_count(interval)
      #   ParticipantDeclaration::NPQ
      #     .submitted_between(interval.begin, interval.end)
      #     .for_lead_provider_and_course(cpd_lead_provider, course_identifier)
      #     .submitted
      #     .unique_id
      #     .count
      # end
    end
  end
end
