# frozen_string_literal: true

module Admin
  class SchoolsController < Admin::BaseController
    skip_after_action :verify_authorized, only: :index

    def index
      @query = params[:query]
      @schools = policy_scope(School).order(:name).page(params[:page]).per(20)
      if @query.present?
        @schools = @schools.search_by_name_or_urn(@query)
      end
    end
  end
end
