# frozen_string_literal: true

class Admin::BaseController < ApplicationController
  include Pundit::Authorization

  before_action :authenticate_user!
  before_action :ensure_admin
  before_action :set_paper_trail_whodunnit
  after_action :verify_authorized
  after_action :verify_policy_scoped

  layout "admin"

private

  def ensure_admin
    raise Pundit::NotAuthorizedError, "Forbidden" unless true_user.admin?
  end
end
