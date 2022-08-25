# frozen_string_literal: true

module Schools
  module SetupSchoolCohortHelper
    TRAINING_CONFIRMATION_TEMPLATES = {
      full_induction_programme: :training_confirmation_fip,
      core_induction_programme: :training_confirmation_cip,
      school_funded_fip: :training_confirmation_school_funded_fip,
      design_our_own: :training_confirmation_diy,
    }.freeze

    def training_confirmation_template(training_choice)
      TRAINING_CONFIRMATION_TEMPLATES[training_choice.to_sym].to_s
    end
  end
end
