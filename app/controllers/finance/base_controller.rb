# frozen_string_literal: true

class Finance::BaseController < ApplicationController
  include Pundit

  before_action :authenticate_user!
  before_action :ensure_finance
  after_action :verify_policy_scoped

private

  def ensure_finance
    raise Pundit::NotAuthorizedError, "Forbidden" unless current_user.finance?
  end
end
