# frozen_string_literal: true

# We want to make sure Cohort exists for the seed
[2021, 2022].each do |year|
  Cohort.find_or_create_by!(start_year: year) do |c|
    c.registration_start_date = Date.new(year, 5, 10)
    c.academic_year_start_date = Date.new(year, 9, 1)
  end
end

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
