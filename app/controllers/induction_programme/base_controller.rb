# frozen_string_literal: true

class InductionProgramme::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_induction_coordinator

private

  def ensure_induction_coordinator
    raise Pundit::NotAuthorizedError, "Forbidden" unless current_user.induction_coordinator?
  end
end
