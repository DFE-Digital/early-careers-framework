# frozen_string_literal: true

module Schools
  module Participants
    class Status < BaseComponent
      def initialize(participant_profile:)
        @participant_profile = participant_profile
      end

    private

      attr_reader :participant_profile

      def heading
        t :header, scope: translation_scope
      end

      def content
        Array.wrap(t(:content, scope: translation_scope))
      end

      def translation_scope
        @translation_scope ||= "schools.participants.status.#{profile_status}"
      end

      def profile_status
        if (eligibility = participant_profile.ecf_participant_eligibility)
          return :ineligible if eligibility.ineligible_status?

          if eligibility.eligible_status?
            return :eligible_cip if participant_profile.school_cohort.cip?
            return participant_profile.school_cohort.delivery_partner ? :eligible_fip : :eligible_fip_no_partner if participant_profile.school_cohort.fip?
          end
        end

        return :checking_eligibility if participant_profile.ecf_participant_validation_data.present?
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
