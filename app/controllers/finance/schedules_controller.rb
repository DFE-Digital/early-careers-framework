# frozen_string_literal: true

module Finance
  class SchedulesController < BaseController
    def index
      @schedules = Finance::Schedule.includes(:cohort, :milestones).order(:schedule_identifier)
    end

    def show
      @schedule = Finance::Schedule.includes(:cohort, :milestones).find(params[:id])
    end
  end
end
