# frozen_string_literal: true

module Schools
  module Participants
    class Status < BaseComponent
      def initialize(induction_record:, mentees: [])
        @induction_record = induction_record
        @mentees = mentees
      end

      private

      attr_reader :induction_record, :mentees

      delegate :participant_profile, to: :induction_record
      delegate :delivery_partner, to: :induction_record
      delegate :school_cohort, to: :induction_record
      delegate :ecf_participant_eligibility, to: :participant_profile
      delegate :ecf_participant_validation_data, to: :participant_profile
      delegate :core_induction_programme?, to: :school_cohort

      def content
        Array.wrap(t(:content, scope: translation_scope,
                     contact_us: render(MailToSupportComponent.new("contact us")),
                     start_date: induction_record.start_date,
                     end_date: induction_record.end_date))
             .map(&:html_safe)
      end

      def heading
        govuk_tag(text: t(:header, scope: translation_scope),
                  colour: t(:colour, scope: translation_scope))
      end

      def profile_status
        return :no_longer_being_trained_sit if participant_withdrawn?
        return :no_longer_being_trained_provider if participant_withdrawn_from_training?
        return :check_email_address if email_address_not_deliverable?
        return :contacted_for_information if awaiting_contact_from_participant?
        return :no_trn_provided if has_no_trn?
        return :pending if active_flags_need_checking?
        return :pending if has_different_trn?
        return :waiting_for_qts if waiting_for_qts?
        return :no_induction_start_date if has_no_induction?
        return :statutory_induction_completed if previous_induction_or_participation?
        return :exempt if exempt_from_induction?
        return :duplicate_profile if duplicate_profile?
        return :no_longer_being_trained_provider if active_flags_verified?
        return :not_qualified if ect_not_qualified?
        return :training_deferred if training_status_deferred?
        return :training_completed if participant_completed?
        return :leaving_your_school if participant_leaving?
        return :joining_your_school if participant_joining?
        return :mentoring if participant_profile.mentor?
        return :not_mentoring if participant_not_mentoring?

        :training
      end

      def translation_scope
        @translation_scope ||= "schools.participants.status.#{profile_status}"
      end

      # Status checks
      def active_flags_need_checking?
        ecf_participant_eligibility&.manual_check_status? && ecf_participant_eligibility.active_flags_reason?
      end

      def active_flags_verified?
        ecf_participant_eligibility&.ineligible_status? && ecf_participant_eligibility.active_flags_reason?
      end

      def awaiting_contact_from_participant?
        request_for_details_email&.delivered? && ecf_participant_validation_data.nil?
      end

      def duplicate_profile?
        participant_profile.duplicate?
      end

      def ect_not_qualified?
        participant_profile&.ect? &&
          ecf_participant_eligibility&.ineligible_status? &&
          ecf_participant_eligibility.no_qts_reason?
      end

      def email_address_not_deliverable?
        request_for_details_email&.failed?
      end

      def exempt_from_induction?
        ecf_participant_eligibility&.ineligible_status? && ecf_participant_eligibility.exempt_from_induction_reason?
      end

      def has_different_trn?
        ecf_participant_eligibility&.manual_check_status? && ecf_participant_eligibility.different_trn_reason?
      end

      def has_no_induction?
        ecf_participant_eligibility&.manual_check_status? && ecf_participant_eligibility.no_induction_reason?
      end

      def has_no_trn?
        induction_record.trn.blank?
      end

      def participant_completed?
        induction_record.completed_induction_status?
      end

      def participant_joining?
        induction_record.active_induction_status? &&
          induction_record.start_date.future? &&
          induction_record.school_transfer?
      end

      def participant_leaving?
        induction_record&.leaving_induction_status?
      end

      def participant_not_mentoring?
        induction_record.mentor? && mentees.none?
      end

      def participant_withdrawn?
        induction_record&.withdrawn_induction_status?
      end

      def participant_withdrawn_from_training?
        induction_record&.training_status_withdrawn?
      end

      def previous_induction_or_participation?
        ecf_participant_eligibility&.ineligible_status? &&
          (ecf_participant_eligibility.previous_induction_reason? ||
            ecf_participant_eligibility.previous_participation_reason?)
      end

      def request_for_details_email
        return @latest_email if defined?(@latest_email)

        @latest_email = Email.associated_with(participant_profile).tagged_with(:request_for_details).latest
      end

      def training_status_deferred?
        induction_record&.training_status_deferred?
      end

      def waiting_for_qts?
        ecf_participant_eligibility&.manual_check_status? && ecf_participant_eligibility.no_qts_reason?
      end
    end
  end
end
