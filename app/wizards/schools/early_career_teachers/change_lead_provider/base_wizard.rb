# frozen_string_literal: true

module Schools
  module EarlyCareerTeachers
    module ChangeLeadProvider
      class BaseWizard < DfE::Wizard::Base
        attr_accessor :school_id, :start_year, :participant_id

        steps do
          [
            {
              intro: IntroStep,
              start: StartStep,
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
      end
    end
  end
end
