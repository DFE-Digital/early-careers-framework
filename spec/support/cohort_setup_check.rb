# frozen_string_literal: true

# prevent sending the user to setup the cohort when testing other journies
def disable_cohort_setup_check
  allow_any_instance_of(Schools::BaseController).to receive(:redirect_to_setup_cohort)
end
