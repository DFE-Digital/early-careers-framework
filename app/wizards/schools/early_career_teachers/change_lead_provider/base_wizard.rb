# frozen_string_literal: true

# Patching until https://github.com/DFE-Digital/dfe-wizard/issues/1 is resolved.
# The alternative is to pick unique wizard step names.
module DfE
  module Wizard
    class Step
      def self.model_name
        activemodel_model_name = super
        step_model_name = ActiveModel::Name.new(self, nil, formatted_name.demodulize)
        step_model_name.i18n_key = activemodel_model_name.i18n_key
        step_model_name
      end
    end
  end
end

module Schools
  module EarlyCareerTeachers
    module ChangeLeadProvider
      class BaseWizard < DfE::Wizard::Base
        attr_accessor :current_user, :school_id, :start_year, :participant_id, :store

        steps do
          [
            {
              intro: IntroStep,
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
            email: preferred_email,
            school:,
            start_year:,
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
          @participant ||= ParticipantProfile::ECT.find(participant_id)
        end

        def preferred_email
          store.attrs_for(:email)[:email] || participant.user.email
        end

        def complete?
          store.attrs_for(:check_your_answers)&.fetch(:complete, nil) == "true"
        end
      end
    end
  end
end
