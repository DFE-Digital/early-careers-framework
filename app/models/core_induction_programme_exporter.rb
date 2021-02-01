# frozen_string_literal: true

class CoreInductionProgrammeExporter
  def run
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
  end
end
