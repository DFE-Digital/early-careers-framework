# frozen_string_literal: true

module DeliveryPartners
  module Participants
    class TableRow < BaseComponent
      with_collection_parameter :participant_profile

      delegate :user, :teacher_profile, :school_cohort, :schedule, :training_status, :ecf_participant_eligibility,
               to: :participant_profile

      delegate :full_name, :email, :user_description,
               to: :user

      def initialize(participant_profile:)
        @participant_profile = participant_profile
      end

      def status_tag
        title = t(".status.#{status_name}.title")
        description = t(".status.#{status_name}.description")

        if description.present?
          content_tag(:strong, title) +
            content_tag(:p, description, class: "govuk-body-s")
        else
          content_tag(:strong, title)
        end
      end

      def lead_provider_name
        participant_profile.induction_records.active.latest&.induction_programme&.partnership&.lead_provider&.name
      end

    private

      attr_reader :participant_profile

      def status_name
        if participant_profile.training_status_withdrawn?
          "no_longer_being_trained"

        elsif eligible? && participant_profile.single_profile?
          "training_or_eligible_for_training"

        elsif eligible? && participant_profile.primary_profile?
          "training_or_eligible_for_training"

        elsif ineligible? && mentor_with_duplicate_profile?
          "training_or_eligible_for_training"

        elsif participant_profile.manual_check_needed?
          "dfe_checking_eligibility"

        elsif nqt_plus_one? && ineligible?
          "not_eligible_for_funded_training"

        elsif participant_has_no_qts? && ineligible?
          "checking_qts"

        elsif ineligible? && mentor_was_in_early_rollout? && on_fip?
          "training_or_eligible_for_training"

        elsif ineligible? && mentor_was_in_early_rollout?
          "training_or_eligible_for_training"

        elsif ineligible?
          "not_eligible_for_funded_training"

        elsif latest_email&.delivered?
          "contacted_for_information"

        elsif latest_email&.failed?
          "contacted_for_information"

        else
          "contacted_for_information"
        end
      end

      def latest_email
        @latest_email ||= Email.associated_with(participant_profile).tagged_with(:request_for_details).latest
      end

      def eligible?
        ecf_participant_eligibility&.eligible_status?
      end

      def ineligible?
        ecf_participant_eligibility&.ineligible_status?
      end

      def mentor_was_in_early_rollout?
        return unless participant_profile.mentor?

        ecf_participant_eligibility&.previous_participation_reason?
      end

      def mentor_with_duplicate_profile?
        return unless participant_profile.mentor?

        ecf_participant_eligibility&.duplicate_profile_reason?
      end

      def on_fip?
        participant_profile&.school_cohort&.full_induction_programme?
      end

      def nqt_plus_one?
        ecf_participant_eligibility&.previous_induction_reason?
      end

      def participant_has_no_qts?
        ecf_participant_eligibility&.no_qts_reason?
      end
    end
  end
end
