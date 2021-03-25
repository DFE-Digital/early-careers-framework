# frozen_string_literal: true

class Schools::BaseController < ApplicationController
  include Pundit

  before_action :authenticate_user!
  before_action :ensure_school_user
  before_action :set_paper_trail_whodunnit
  after_action :verify_authorized
  after_action :verify_policy_scoped

private

  def ensure_school_user
    raise Pundit::NotAuthorizedError, "Forbidden" unless current_user.induction_coordinator?
  end
end
