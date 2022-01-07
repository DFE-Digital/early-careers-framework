# frozen_string_literal: true

require "csv"

def cohort_2021
  Cohort.find_or_create_by!(start_year: 2021)
end

ecf_september_standard_2021 = Finance::Schedule::ECF.find_or_create_by!(name: "ECF September standard 2021") do |s|
  s.cohort = cohort_2021
end
ecf_september_standard_2021.update!(schedule_identifier: "ecf-september-standard-2021")
ecf_september_standard_2021.update!(cohort: cohort_2021)
[
  { name: "Output 1 - Participant Start", start_date: Date.new(2021, 9, 1), milestone_date: Date.new(2021, 11, 30), payment_date: Date.new(2021, 11, 30), declaration_type: "started" },
  { name: "Output 2 – Retention Point 1", start_date: Date.new(2021, 11, 1), milestone_date: Date.new(2022, 1, 31), payment_date: Date.new(2022, 2, 28), declaration_type: "retained-1" },
  { name: "Output 3 – Retention Point 2", start_date: Date.new(2022, 2, 1), milestone_date: Date.new(2022, 4, 30), payment_date: Date.new(2022, 5, 31), declaration_type: "retained-2" },
  { name: "Output 4 – Retention Point 3", start_date: Date.new(2022, 5, 1), milestone_date: Date.new(2022, 9, 30), payment_date: Date.new(2022, 10, 31), declaration_type: "retained-3" },
  { name: "Output 5 – Retention Point 4", start_date: Date.new(2022, 10, 1), milestone_date: Date.new(2023, 1, 31), payment_date: Date.new(2023, 2, 28), declaration_type: "retained-4" },
  { name: "Output 6 – Participant Completion", start_date: Date.new(2023, 2, 1), milestone_date: Date.new(2023, 4, 30), payment_date: Date.new(2023, 5, 31), declaration_type: "completed" },
].each do |hash|
  Finance::Milestone.find_or_create_by!(
    schedule: ecf_september_standard_2021,
    name: hash[:name],
    start_date: hash[:start_date],
    milestone_date: hash[:milestone_date],
    payment_date: hash[:payment_date],
  ).update!(declaration_type: hash[:declaration_type])
end

ecf_january_standard_2021 = Finance::Schedule::ECF.find_or_create_by!(name: "ECF January standard 2021") do |s|
  s.cohort = cohort_2021
end
ecf_january_standard_2021.update!(schedule_identifier: "ecf-january-standard-2021")
ecf_january_standard_2021.update!(cohort: cohort_2021)
[
  { name: "Output 1 - Participant Start", start_date: Date.new(2022, 1, 1), milestone_date: Date.new(2022, 1, 31), payment_date: Date.new(2022, 2, 28), declaration_type: "started" },
  { name: "Output 2 – Retention Point 1", start_date: Date.new(2022, 2, 1), milestone_date: Date.new(2022, 4, 30), payment_date: Date.new(2022, 5, 31), declaration_type: "retained-1" },
  { name: "Output 3 – Retention Point 2", start_date: Date.new(2022, 5, 1), milestone_date: Date.new(2022, 9, 30), payment_date: Date.new(2022, 10, 31), declaration_type: "retained-2" },
  { name: "Output 4 – Retention Point 3", start_date: Date.new(2022, 10, 1), milestone_date: Date.new(2023, 1, 31), payment_date: Date.new(2023, 2, 28), declaration_type: "retained-3" },
  { name: "Output 5 – Retention Point 4", start_date: Date.new(2023, 2, 1), milestone_date: Date.new(2023, 4, 30), payment_date: Date.new(2023, 5, 31), declaration_type: "retained-4" },
  { name: "Output 6 – Participant Completion", start_date: Date.new(2023, 2, 1), milestone_date: Date.new(2023, 10, 31), payment_date: Date.new(2023, 11, 30), declaration_type: "completed" },
].each do |hash|
  Finance::Milestone.find_or_create_by!(
    schedule: ecf_january_standard_2021,
    name: hash[:name],
    start_date: hash[:start_date],
    milestone_date: hash[:milestone_date],
    payment_date: hash[:payment_date],
  ).update!(declaration_type: hash[:declaration_type])
end

npq_specialist_november_2021 = Finance::Schedule::NPQSpecialist.find_or_create_by!(name: "NPQ Specialist November 2021", schedule_identifier: "npq-specialist-november-2021") do |s|
  s.cohort = cohort_2021
end
npq_specialist_november_2021.update!(cohort: cohort_2021)
[
  { name: "Output 1 - Participant Start", start_date: Date.new(2021, 11, 1), milestone_date: Date.new(2021, 12, 25), payment_date: Date.new(2022, 1, 31), declaration_type: "started" },
  { name: "Output 2 – Retention Point 1", start_date: Date.new(2021, 12, 26), milestone_date: Date.new(2022, 6, 25), payment_date: Date.new(2022, 7, 31), declaration_type: "retained-1" },
  { name: "Output 3 – Participant Completion", start_date: Date.new(2022, 6, 26), milestone_date: Date.new(2022, 12, 25), payment_date: Date.new(2023, 1, 31), declaration_type: "completed" },
].each do |hash|
  Finance::Milestone.find_or_create_by!(
    schedule: npq_specialist_november_2021,
    name: hash[:name],
    start_date: hash[:start_date],
    milestone_date: hash[:milestone_date],
    payment_date: hash[:payment_date],
    declaration_type: hash[:declaration_type],
  )
end

npq_leadership_november_2021 = Finance::Schedule::NPQLeadership.find_or_create_by!(name: "NPQ Leadership November 2021", schedule_identifier: "npq-leadership-november-2021") do |s|
  s.cohort = cohort_2021
end
npq_leadership_november_2021.update!(cohort: cohort_2021)
[
  { name: "Output 1 - Participant Start", start_date: Date.new(2021, 11, 1), milestone_date: Date.new(2021, 12, 25), payment_date: Date.new(2022, 1, 31), declaration_type: "started" },
  { name: "Output 2 – Retention Point 1", start_date: Date.new(2021, 12, 26), milestone_date: Date.new(2022, 6, 25), payment_date: Date.new(2022, 7, 31), declaration_type: "retained-1" },
  { name: "Output 3 – Retention Point 2", start_date: Date.new(2022, 6, 26), milestone_date: Date.new(2022, 11, 25), payment_date: Date.new(2022, 12, 31), declaration_type: "retained-2" },
  { name: "Output 4 – Participant Completion", start_date: Date.new(2022, 11, 26), milestone_date: Date.new(2023, 6, 25), payment_date: Date.new(2023, 7, 31), declaration_type: "completed" },
].each do |hash|
  Finance::Milestone.find_or_create_by!(
    schedule: npq_leadership_november_2021,
    name: hash[:name],
    start_date: hash[:start_date],
    milestone_date: hash[:milestone_date],
    payment_date: hash[:payment_date],
    declaration_type: hash[:declaration_type],
  )
end

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
  path_to_csv: Rails.root.join("db/seeds/schedules/ecf_standard.csv"),
  klass: Finance::Schedule::ECF,
).call
