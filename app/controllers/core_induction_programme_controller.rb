# frozen_string_literal: true

class CoreInductionProgrammeController < ApplicationController
  def show
    @course_years = CourseYear.all
  end

  def download_export
    if @current_user&.admin?
      SeedDump.dump(
        CoreInductionProgramme,
        file: "db/seeds/cip_seed_dump.rb",
        exclude: %i[created_at updated_at],
        import: true,
      )
      SeedDump.dump(
        CourseYear.all,
        file: "db/seeds/cip_seed_dump.rb",
        exclude: %i[created_at updated_at],
        import: true,
        append: true,
      )
      SeedDump.dump(
        CourseModule.all,
        file: "db/seeds/cip_seed_dump.rb",
        exclude: %i[created_at updated_at],
        import: true,
        append: true,
      )
      SeedDump.dump(
        CourseLesson.all,
        file: "db/seeds/cip_seed_dump.rb",
        exclude: %i[created_at updated_at],
        import: true,
        append: true,
      )

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
