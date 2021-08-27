# frozen_string_literal: true

module Admin
  class SchoolsController < Admin::BaseController
    skip_after_action :verify_authorized, only: :index
    skip_after_action :verify_policy_scoped, only: :show

    before_action :load_school, only: :show

    def index
      @query = params[:query]

      @schools = policy_scope(School)
        .includes(:induction_coordinators, :local_authority)
        .ransack(induction_coordinators_email_or_urn_or_name_cont: @query).result
        .order(:name)
        .page(params[:page])
        .per(10)
    end

    def show
      authorize @school
      @induction_coordinator = @school.induction_coordinators&.first
    end

  private

    def load_school
      @school = School.eligible_or_cip_only.friendly.find(params[:id])
    end
  end
end
