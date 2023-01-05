# frozen_string_literal: true

module Admin
  class SchoolsController < Admin::BaseController
    skip_after_action :verify_authorized, only: :index
    skip_after_action :verify_policy_scoped, only: :show

    before_action :load_school, only: :show

    def index
      @query = params[:query]

      @pagy, @schools = pagy(policy_scope(School)
                               .distinct
                               .includes(:induction_coordinators, :local_authority)
                               .ransack(induction_coordinators_email_or_urn_or_name_or_postcode_cont: @query)
                               .result
                               .order(:name), page: params[:page], items: 10)
    end

    def show
      authorize @school
      @induction_coordinator = @school.induction_coordinators&.first
      set_2020_link
    end

  private

    def load_school
      @school = School.eligible_or_cip_only.friendly.find(params[:id])
    end

    def set_2020_link
      cohort_2020 = @school.school_cohorts.find_by(cohort: Cohort.find_by(start_year: 2020))
      @link_2020 = cohort_2020 ? admin_school_cohort2020_path(school_id: @school.slug) : start_schools_year_2020_path(school_id: @school.slug)
      @link_text_2020 = cohort_2020 ? "View 2020 cohort for NQT+1s" : "Set up 2020 cohort for NQT+1s. Right click and copy link address for use in macros."
    end
  end
end
