# frozen_string_literal: true

module Schools
  module CohortSetupHelper
    TRAINING_CONFIRMATION_TEMPLATES = {
      full_induction_programme: :training_confirmation_fip,
      core_induction_programme: :training_confirmation_cip,
      school_funded_fip: :training_confirmation_school_funded_fip,
      design_our_own: :training_confirmation_diy,
    }.freeze

    def training_confirmation_template(training_choice)
      TRAINING_CONFIRMATION_TEMPLATES[training_choice.to_sym].to_s
    end

    def programme_radio_options(form, attr_name, choices, legend)
      args = [
        attr_name,
        choices,
        :id,
        :name,
      ]
      args << :description if FeatureFlag.active?(:programme_type_changes_2025)
      form.govuk_collection_radio_buttons(*args, legend: { text: legend, tag: "h1", size: "l" })
    end
  end
end
