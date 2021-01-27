# frozen_string_literal: true

class CoreInductionProgrammeController < ApplicationController
  def show
    @course_years = CourseYear.all
  end

  def download_export
    unless @current_user&.admin_profile
      redirect_to cip_path and return
    end

    system "bundle exec rake cip_seed_dump"
    send_file(
      Rails.root.join("db/seeds/cip_seed_dump.rb"),
      filename: "cip_seed_dump.rb",
      type: "text/plain",
    )
  end
end
