# frozen_string_literal: true

require "rake"

Rake::Task.clear
GovukRailsBoilerplate::Application.load_tasks

class CoreInductionProgrammeController < ApplicationController
  def show
    @course_years = CourseYear.all
  end

  def download_export
    if @current_user&.admin?
      Rake::Task[:cip_seed_dump].invoke
      send_file(
        Rails.root.join("db/seeds/cip_seed_dump.rb"),
        filename: "cip_seed_dump.rb",
        type: "text/plain",
      )
    else
      redirect_to cip_path
    end
  end
end
