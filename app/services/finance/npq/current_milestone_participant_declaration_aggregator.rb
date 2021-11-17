# frozen_string_literal: true

module Finance
  module NPQ
    class CurrentMilestoneParticipantDeclarationAggregator
      class << self
        def call(cpd_lead_provider:, course_identifier:)
          new(cpd_lead_provider: cpd_lead_provider, course_identifier: course_identifier).aggregate
        end
      end

      def aggregate
        {
          current_participants_count: current_participants_count,
          total_participant_eligible_and_payable_count: total_participant_eligible_and_payable_count,
          total_participant_not_paid_count: total_participant_not_paid_count,
        }
      end

    private

      attr_accessor :cpd_lead_provider, :course_identifier

      def initialize(cpd_lead_provider:, course_identifier:)
        self.cpd_lead_provider       = cpd_lead_provider
        self.course_identifier       = course_identifier
      end

      def current_participants_count
        ParticipantDeclaration::NPQ
          .for_lead_provider_and_course(cpd_lead_provider, course_identifier)
          .where.not(state: ParticipantDeclaration.states[:paid])
          .unique_id
          .count
      end

      def total_participant_eligible_and_payable_count
        ParticipantDeclaration::NPQ
          .for_lead_provider_and_course(cpd_lead_provider, course_identifier)
          .eligible_or_payable
          .unique_id
          .count
      end

      def total_participant_not_paid_count
        ParticipantDeclaration::NPQ
          .for_lead_provider_and_course(cpd_lead_provider, course_identifier)
          .where.not(state: ParticipantDeclaration.states.values_at("payable", "eligible"))
          .unique_id
          .count
      end
    end
  end
end
