# frozen_string_literal: true

module Schools
  module Participants
    class CohortedStatus < BaseComponent
      def initialize(participant_profile:)
        @participant_profile = participant_profile
      end

    private

      attr_reader :participant_profile

      delegate :school_cohort, to: :participant_profile
      delegate :core_induction_programme?, to: :school_cohort
      delegate :delivery_partner, to: :school_cohort

      def heading
        t :header, scope: translation_scope
      end

      def content
        Array.wrap(t(:content, scope: translation_scope, contact_us: render(MailToSupportComponent.new("contact us")))).map(&:html_safe)
      end

      def translation_scope
        @translation_scope ||= "schools.participants.status.#{profile_status}"
      end

      def profile_status
        return awaiting_validation_status if participant_profile.ecf_participant_validation_data.blank?
        return :eligible_cip if core_induction_programme?

        FeatureFlag.active?(:eligibility_notifications) ? fip_validation_status : :checking_eligibility
      end

      def fip_validation_status
        if (eligibility = participant_profile.ecf_participant_eligibility)
          return fip_eligible_status if eligibility.eligible_status? || eligibility.duplicate_profile_reason?
          return fip_ineligible_status(eligibility) if eligibility.ineligible_status?
          return fip_manual_check_status(eligibility) if eligibility.manual_check_status?
          return fip_manual_check_status(eligibility) if eligibility.manual_check_status?
        end
        :checking_eligibility
      end

      def fip_eligible_status
        delivery_partner ? :eligible_fip : :eligible_fip_no_partner
      end

      def fip_manual_check_status(eligibility)
        if eligibility.no_qts_reason?
          participant_profile.ect? ? :fip_ect_no_qts : :checking_eligibility
        else
          :checking_eligibility
        end
      end

      def fip_ineligible_status(eligibility)
        case eligibility.reason
        when "previous_induction"
          :ineligible_previous_induction
        when "previous_participation"
          :ero_mentor
        when "active_flags"
          :ineligible_flag
        else
          :ineligible_generic
        end
      end

      def awaiting_validation_status
        return :details_required if latest_email&.delivered?
        return :request_for_details_failed if latest_email&.failed?

        :request_to_be_sent
      end

      def latest_email
        return @latest_email if defined?(@latest_email)

        @latest_email = Email.associated_with(participant_profile).tagged_with(:request_for_details).latest
      end
    end
  end
end
