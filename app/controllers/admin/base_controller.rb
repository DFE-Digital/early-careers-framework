# frozen_string_literal: true

class Admin::BaseController < ApplicationController
  include Pundit

  before_action :authenticate_user!
  before_action :ensure_admin
  after_action :verify_authorized
  after_action :verify_policy_scoped
  before_action :set_paper_trail_whodunnit

private

  def ensure_admin
    raise Pundit::NotAuthorizedError, "Forbidden" unless current_user.admin?
  end
end
