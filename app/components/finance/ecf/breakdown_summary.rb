# frozen_string_literal: true

module Finance
  module ECF
    class BreakdownSummary < BaseComponent
      include ECFPaymentsHelper
      attr_accessor :breakdown_started, :breakdown_retained_1, :lead_provider, :deadline_date

      def initialize(breakdown_started:, breakdown_retained_1:, lead_provider:, deadline_date:)
        @lead_provider = lead_provider
        @breakdown_started = breakdown_started
        @breakdown_retained_1 = breakdown_retained_1
        @deadline_date = deadline_date
      end

    private

      def recruitment_target_ects
        breakdown_started[:breakdown_summary][:ects] +
          breakdown_retained_1[:breakdown_summary][:ects]
      end

      def recruitment_target_mentors
        breakdown_started[:breakdown_summary][:mentors] +
          breakdown_retained_1[:breakdown_summary][:mentors]
      end

      def recruitment_target_participants
        breakdown_started[:breakdown_summary][:participants] +
          breakdown_retained_1[:breakdown_summary][:participants]
      end

      def recruitment_target
        breakdown_started[:breakdown_summary][:recruitment_target]
      end

      def service_fees_participants
        breakdown_started[:service_fees].map { |params| params[:participants] }.inject(&:+)
      end

      def service_fees_total
        breakdown_started[:service_fees].map { |params| params[:monthly] }.inject(&:+)
      end

      def output_payment_participants
        breakdown_started[:output_payments].map { |params| params[:participants] }.inject(&:+) +
          breakdown_retained_1[:output_payments].map { |params| params[:participants] }.inject(&:+)
      end

      def output_payment_total
        breakdown_started[:output_payments].map { |params| params[:subtotal] }.inject(&:+) +
          breakdown_retained_1[:output_payments].map { |params| params[:subtotal] }.inject(&:+)
      end

      def uplift_fees_participants
        breakdown_started[:other_fees][:uplift][:participants]
      end

      def uplift_fees_subtotal
        breakdown_started[:other_fees][:uplift][:subtotal]
      end
    end
  end
end
