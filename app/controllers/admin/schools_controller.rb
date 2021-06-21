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
        .yield_self(&method(:search_query))
        .order(:name)
        .page(params[:page])
        .per(20)
    end

    def show
      authorize @school
      @induction_coordinator = @school.induction_coordinators&.first
    end

  private

    def load_school
      @school = School.eligible.friendly.find(params[:id])
    end

    def search_query(relation)
      if @query.present?
        search_value = "%#{@query}%"

        relation
          .left_joins(:induction_coordinators)
          .where(School.arel_table[:name].matches(search_value)
            .or(School.arel_table[:urn].matches(search_value))
            .or(User.arel_table[:email].matches(search_value)))
      else
        relation
      end
    end
  end
end
