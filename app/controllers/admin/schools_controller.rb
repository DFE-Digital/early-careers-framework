# frozen_string_literal: true

module Admin
  class SchoolsController < Admin::BaseController
    skip_after_action :verify_authorized, only: :index
    skip_after_action :verify_policy_scoped, only: :show

    def index
      @query = params[:query]
      @pagy, @schools = pagy(schools_search, page: params[:page], items: 10)
    end

    def show
      @school = School.eligible_or_cip_only.friendly.find(params[:id])
      authorize @school
      @induction_coordinator = @school.induction_coordinators&.first
      @setup_done = @school.school_cohorts.for_year(2020).present?
    end

  private

    def schools_search
      ::Schools::SearchQuery.new(query: @query, scope: policy_scope(School)).call
    end
  end
end
