# frozen_string_literal: true

class LeadProvider::FilterSchoolsController < LeadProvider::BaseController
  def show
    skip_authorization
    skip_policy_scope

    @school_search_form = SchoolSearchForm.new
  end
end
