# frozen_string_literal: true

# prevent sending the user to setup the cohort when testing other journies
def disable_cohort_setup_check
  allow_any_instance_of(Schools::BaseController).to receive(:redirect_to_setup_cohort)
  # allow_any_instance_of(Schools::DashboardController).to receive(:set_up_new_cohort?).and_return(false)
  # allow_any_instance_of(Schools::DashboardController).to receive(:check_school_cohorts).and_return(false)
end
