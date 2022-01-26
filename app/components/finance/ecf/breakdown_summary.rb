# frozen_string_literal: true

module Finance
  module ECF
    class BreakdownSummary < BaseComponent
      include FinanceHelper
      attr_accessor :lead_provider, :breakdown_started, :breakdown_retained_1, :recruitment_target_ects, :recruitment_target_mentors,
                    :recruitment_target_participants, :recruitment_target, :service_fees_participants, :service_fees_total, :output_payment_participants,
                    :output_payment_total, :uplift_fees_participants, :uplift_fees_subtotal, :deadline_date

    private

      def initialize(breakdown_started:, breakdown_retained_1:, lead_provider:, deadline_date:)
        @lead_provider = lead_provider
        @breakdown_started = breakdown_started
        @breakdown_retained_1 = breakdown_retained_1
        @recruitment_target_ects = breakdown_started[:breakdown_summary][:ects] + breakdown_retained_1[:breakdown_summary][:ects]
        @recruitment_target_mentors = breakdown_started[:breakdown_summary][:mentors] + breakdown_retained_1[:breakdown_summary][:mentors]
        @recruitment_target_participants = breakdown_started[:breakdown_summary][:participants] + breakdown_retained_1[:breakdown_summary][:participants]
        @recruitment_target = breakdown_started[:breakdown_summary][:recruitment_target] + breakdown_retained_1[:breakdown_summary][:recruitment_target]
        @service_fees_participants = breakdown_started[:service_fees].map { |params| params[:participants] }.inject(&:+) + breakdown_retained_1[:service_fees].map { |params| params[:participants] }.inject(&:+)
        @service_fees_total = breakdown_started[:service_fees].map { |params| params[:monthly] }.inject(&:+) + breakdown_retained_1[:service_fees].map { |params| params[:monthly] }.inject(&:+)
        @output_payment_participants = breakdown_started[:output_payments].map { |params| params[:participants] }.inject(&:+) + breakdown_retained_1[:output_payments].map { |params| params[:participants] }.inject(&:+)
        @output_payment_total = breakdown_started[:output_payments].map { |params| params[:subtotal] }.inject(&:+) + breakdown_retained_1[:output_payments].map { |params| params[:subtotal] }.inject(&:+)
        @uplift_fees_participants = breakdown_started[:other_fees][:uplift][:participants]
        @uplift_fees_subtotal = breakdown_started[:other_fees][:uplift][:subtotal]
        @deadline_date = deadline_date
      end
    end
  end
end
