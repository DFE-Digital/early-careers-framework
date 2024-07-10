# frozen_string_literal: true

module Schools
  module ChangeLeadProvider
    class BaseWizard < DfE::Wizard::Base
      attr_accessor :current_user, :school_id, :start_year, :participant_id, :store

      steps do
        [
          {
            start: StartStep,
            contact_providers: ContactProvidersStep,
            email: EmailStep,
            lead_provider: LeadProviderStep,
            check_your_answers: CheckYourAnswersStep,
            success: SuccessStep,
          },
        ]
      end

      def default_path_arguments
        { school_id:, participant_id:, start_year: }
      end

      def save!
        current_step.save! if current_step.respond_to?(:save!)

        if complete?
          create_support_query!
          store.destroy # rubocop:disable Rails/SaveBang
        end
      end

      def create_support_query!
        CreateChangeLeadProviderSupportQuery.call(
          current_user:,
          participant:,
          school:,
          academic_year:,
          current_lead_provider:,
          new_lead_provider:,
        )
      end

      def current_lead_provider
        @current_lead_provider ||= school.lead_provider(start_year)
      end

      def new_lead_provider
        @new_lead_provider ||= LeadProvider.find(store.attrs_for(:lead_provider)[:lead_provider_id])
      end

      def school
        @school ||= School.find(school_id)
      end

      def participant
        return unless participant_change_request?

        @participant ||= ParticipantProfile::ECT.find(participant_id)
      end

      def preferred_email
        store.attrs_for(:email)[:email].presence || participant.user.email
      end

      def complete?
        store.attrs_for(:check_your_answers)&.fetch(:complete, nil) == "true"
      end

      def participant_change_request?
        participant_id.present?
      end

      def academic_year
        @academic_year ||= "#{start_year} to #{start_year.to_i + 1}"
      end
    end
  end
end
