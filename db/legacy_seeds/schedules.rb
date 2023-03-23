# frozen_string_literal: true

Importers::CreateCohort.new(path_to_csv: Rails.root.join("db/data/cohorts/cohorts.csv")).call

ActiveRecord::Base.transaction do
  Importers::CreateSchedule.new(
    path_to_csv: Rails.root.join("db/data/schedules/npq_specialist.csv"),
    klass: Finance::Schedule::NPQSpecialist,
  ).call

  Importers::CreateSchedule.new(
    path_to_csv: Rails.root.join("db/data/schedules/npq_leadership.csv"),
    klass: Finance::Schedule::NPQLeadership,
  ).call

  Importers::CreateSchedule.new(
    path_to_csv: Rails.root.join("db/data/schedules/npq_aso.csv"),
    klass: Finance::Schedule::NPQSupport,
  ).call

  Importers::CreateSchedule.new(
    path_to_csv: Rails.root.join("db/data/schedules/npq_ehco.csv"),
    klass: Finance::Schedule::NPQEhco,
  ).call

  Importers::CreateSchedule.new(
    path_to_csv: Rails.root.join("db/data/schedules/ecf_standard.csv"),
    klass: Finance::Schedule::ECF,
  ).call

  Importers::CreateSchedule.new(
    path_to_csv: Rails.root.join("db/data/schedules/ecf_reduced.csv"),
    klass: Finance::Schedule::ECF,
  ).call

  Importers::CreateSchedule.new(
    path_to_csv: Rails.root.join("db/data/schedules/ecf_extended.csv"),
    klass: Finance::Schedule::ECF,
  ).call

  Importers::CreateSchedule.new(
    path_to_csv: Rails.root.join("db/data/schedules/ecf_replacement.csv"),
    klass: Finance::Schedule::Mentor,
  ).call
end
