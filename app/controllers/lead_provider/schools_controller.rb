# frozen_string_literal: true

class LeadProvider::SchoolsController < LeadProvider::BaseController
  def index
    skip_authorization
    skip_policy_scope
  end

  def show
    skip_authorization
    skip_policy_scope
  end
end
