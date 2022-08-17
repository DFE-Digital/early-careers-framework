# frozen_string_literal: true

module Finance
  class SchedulesController < BaseController
    def index
      @cohorts = Cohort.order(start_year: :asc)
    end

    def show
      @schedule = Finance::Schedule.includes(:cohort, :milestones).find(params[:id])
    end
  end
end
