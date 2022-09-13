# frozen_string_literal: true

ActiveRecord::Base.transaction do
  Importers::SeedSchedule.new(
    path_to_csv: Rails.root.join("db/seeds/schedules/npq_specialist.csv"),
    klass: Finance::Schedule::NPQSpecialist,
  ).call

  Importers::SeedSchedule.new(
    path_to_csv: Rails.root.join("db/seeds/schedules/npq_leadership.csv"),
    klass: Finance::Schedule::NPQLeadership,
  ).call

  Importers::SeedSchedule.new(
    path_to_csv: Rails.root.join("db/seeds/schedules/npq_aso.csv"),
    klass: Finance::Schedule::NPQSupport,
  ).call

  Importers::SeedSchedule.new(
    path_to_csv: Rails.root.join("db/seeds/schedules/npq_ehco.csv"),
    klass: Finance::Schedule::NPQEhco,
  ).call

  Importers::SeedSchedule.new(
    path_to_csv: Rails.root.join("db/seeds/schedules/ecf_standard.csv"),
    klass: Finance::Schedule::ECF,
  ).call

  Importers::SeedSchedule.new(
    path_to_csv: Rails.root.join("db/seeds/schedules/ecf_reduced.csv"),
    klass: Finance::Schedule::ECF,
  ).call

  Importers::SeedSchedule.new(
    path_to_csv: Rails.root.join("db/seeds/schedules/ecf_extended.csv"),
    klass: Finance::Schedule::ECF,
  ).call

  Importers::SeedSchedule.new(
    path_to_csv: Rails.root.join("db/seeds/schedules/ecf_replacement.csv"),
    klass: Finance::Schedule::Mentor,
  ).call
end
