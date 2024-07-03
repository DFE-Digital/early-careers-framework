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
          step_params.each do |key, value|
            store.set(key, value)
          end

          if store.complete?
            create_support_query!
            store.destroy
          end
        end

        def create_support_query!
          SupportQuery.create!(
            message:,
            user: current_user,
            subject:,
            additional_information:,
          ).tap(&:enqueue_support_query_sync_job)
        end

        def subject
          "change-participant-lead-provider"
        end

        def message
          I18n.t(
            "schools.early_career_teachers.change_lead_provider.support_query.message",
            current_user: current_user.full_name,
            participant: participant.full_name,
            email:,
            school: school.name,
            current_lead_provider: current_lead_provider.name,
            new_lead_provider: new_lead_provider.name,
          )
        end

        def additional_information
          I18n.t(
            "schools.early_career_teachers.change_lead_provider.support_query.additional_information",
            academic_year: start_year,
            participant_id:,
            school: school.name,
            urn: school.urn,
          )
        end

        def current_lead_provider
          @current_lead_provider ||= school.lead_provider(start_year)
        end

        def new_lead_provider
          @new_lead_provider ||= LeadProvider.find(store.lead_provider_id)
        end

        def school
          @school ||= School.find_by(id: school_id)
        end

        def participant
          @participant ||= ParticipantProfile::ECT.find(participant_id)
        end

        def email
          store.email || participant.user.email
        end
      end
    end
  end
end
