# frozen_string_literal: true

module Admin
  class SchoolsController < Admin::BaseController
    skip_after_action :verify_authorized, only: :index
    skip_after_action :verify_policy_scoped, only: :show

    before_action :load_school, only: :show

    def index
      @query = params[:query]
      @schools = policy_scope(School).includes(:local_authorities, :induction_coordinators)
                                     .order(:name)
                                     .page(params[:page])
                                     .per(20)
      if @query.present?
        @schools = @schools.search_by_name_or_urn(@query)
      end
    end

    def show
      authorize @school
      @induction_coordinator = @school.induction_coordinators&.first
    end

  private

    def load_school
      @school = School.eligible.find(params[:id])
    end
  end
end
