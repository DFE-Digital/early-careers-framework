# frozen_string_literal: true

class Schools::CohortsController < Schools::BaseController
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

  before_action :set_school_cohort

  def show; end
end
