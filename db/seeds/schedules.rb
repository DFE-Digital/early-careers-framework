# frozen_string_literal: true

ecf_september_standard_2021 = Finance::Schedule.find_or_create_by!(name: "ECF September standard 2021")
ecf_september_standard_2021.update!(schedule_identifier: "ecf-september-standard-2021")
[
  { name: "Output 1 - Participant Start", start_date: Date.new(2021, 9, 1), milestone_date: Date.new(2021, 10, 31), payment_date: Date.new(2021, 11, 30) },
  { name: "Output 2 – Retention Point 1", start_date: Date.new(2021, 11, 1), milestone_date: Date.new(2022, 1, 31), payment_date: Date.new(2022, 2, 28) },
  { name: "Output 3 – Retention Point 2", start_date: Date.new(2022, 2, 1), milestone_date: Date.new(2022, 4, 30), payment_date: Date.new(2022, 5, 31) },
  { name: "Output 4 – Retention Point 3", start_date: Date.new(2022, 5, 1), milestone_date: Date.new(2022, 9, 30), payment_date: Date.new(2022, 10, 31) },
  { name: "Output 5 – Retention Point 4", start_date: Date.new(2022, 10, 1), milestone_date: Date.new(2023, 1, 31), payment_date: Date.new(2023, 2, 28) },
  { name: "Output 6 – Participant Completion", start_date: Date.new(2023, 2, 1), milestone_date: Date.new(2023, 4, 30), payment_date: Date.new(2023, 5, 31) },
].each do |hash|
  Finance::Milestone.find_or_create_by!(
    schedule: ecf_september_standard_2021,
    name: hash[:name],
    start_date: hash[:start_date],
    milestone_date: hash[:milestone_date],
    payment_date: hash[:payment_date],
  )
end

ecf_september_extended_2021 = Finance::Schedule.find_or_create_by!(name: "ECF September extended 2021")
ecf_september_extended_2021.update!(schedule_identifier: "ecf-september-extended-2021")
[
  { name: "Output 1 - Participant Start", start_date: Date.new(2021, 9, 1), milestone_date: Date.new(2021, 10, 31), payment_date: Date.new(2021, 11, 30) },
  { name: "Output 2 – Retention Point 1", start_date: Date.new(2021, 11, 1), milestone_date: Date.new(2022, 4, 30), payment_date: Date.new(2022, 5, 31) },
  { name: "Output 3 – Retention Point 2", start_date: Date.new(2022, 5, 1), milestone_date: Date.new(2022, 9, 30), payment_date: Date.new(2022, 10, 31) },
  { name: "Output 4 – Retention Point 3", start_date: Date.new(2022, 10, 1), milestone_date: Date.new(2023, 4, 30), payment_date: Date.new(2023, 5, 31) },
  { name: "Output 5 – Retention Point 4", start_date: Date.new(2023, 5, 1), milestone_date: Date.new(2023, 10, 31), payment_date: Date.new(2023, 11, 30) },
  { name: "Output 6 – Participant Completion", start_date: Date.new(2023, 11, 1), milestone_date: Date.new(2024, 4, 30), payment_date: Date.new(2024, 5, 31) },
].each do |hash|
  Finance::Milestone.find_or_create_by!(
    schedule: ecf_september_extended_2021,
    name: hash[:name],
    start_date: hash[:start_date],
    milestone_date: hash[:milestone_date],
    payment_date: hash[:payment_date],
  )
end
