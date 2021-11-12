# frozen_string_literal: true

module Finance
  module NPQ
    class CurrentMilestoneParticipantDeclarationAggregator < Finance::ParticipantAggregator
      class << self
        def call(cpd_lead_provider:, course_identifier:)
          new(cpd_lead_provider: cpd_lead_provider, course_identifier: course_identifier).aggregate
        end
      end

      def aggregate
        {
          current_participants_count: current_participants_count,
          total_participant_paid_count: total_participant_paid_count,
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
          .unique_id
          .where.not(ParticipantDeclaration::NPQ.paid.where_values_hash).count
      end

      def total_participant_paid_count
        ParticipantDeclaration::NPQ
          .for_lead_provider_and_course(cpd_lead_provider, course_identifier)
          .unique_id
          .eligible
          .payable.count
      end

      def total_participant_not_paid_count
        ParticipantDeclaration::NPQ
          .for_lead_provider_and_course(cpd_lead_provider, course_identifier)
          .unique_id
          .where.not(ParticipantDeclaration::NPQ.eligible.where_values_hash)
          .where.not(ParticipantDeclaration::NPQ.payable.where_values_hash).count
      end
    end
  end
end
