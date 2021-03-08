# frozen_string_literal: true

class CoreInductionProgrammeExporter
  def run
    SeedDump.dump(
      CoreInductionProgramme,
      file: "db/seeds/cip_seed_dump.rb",
      exclude: %i[created_at updated_at],
      import: true,
    )

    years = CourseYear.order(:title)
    SeedDump.dump(
      years,
      file: "db/seeds/cip_seed_dump.rb",
      exclude: %i[created_at updated_at],
      import: true,
      append: true,
    )

    modules = years.map(&:course_modules_in_order).flatten
    SeedDump.dump(
      modules,
      file: "db/seeds/cip_seed_dump.rb",
      exclude: %i[created_at updated_at],
      import: true,
      append: true,
    )

    lessons = modules.map(&:course_lessons_in_order).flatten
    SeedDump.dump(
      lessons,
      file: "db/seeds/cip_seed_dump.rb",
      exclude: %i[created_at updated_at],
      import: true,
      append: true,
    )

    parts = lessons.map(&:course_lesson_parts_in_order).flatten
    SeedDump.dump(
      parts,
      file: "db/seeds/cip_seed_dump.rb",
      exclude: %i[created_at updated_at],
      import: true,
      append: true,
    )
  end
end
