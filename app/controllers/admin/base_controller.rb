# frozen_string_literal: true

class Admin::BaseController < ApplicationController
  include Pundit::Authorization

  before_action :authenticate_user!
  before_action :ensure_admin
  before_action :set_paper_trail_whodunnit
  after_action :verify_authorized
  after_action :verify_policy_scoped

  layout "admin"

  helper_method :breadcrumbs

  def breadcrumbs
    @breadcrumbs ||= []
  end

  def add_breadcrumb(name, path = nil)
    breadcrumbs << helpers.govuk_breadcrumb_link_to("Schools", admin_schools_path)
    breadcrumbs << helpers.govuk_breadcrumb_link_to(name, path)
  end

private

  def ensure_admin
    raise Pundit::NotAuthorizedError, "Forbidden" unless true_user.admin?
  end
end
