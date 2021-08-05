# frozen_string_literal: true

ecf_september_standard_2021 = Schedule.find_or_create_by!(name: "ECF September standard 2021")
[
  { name: "Output 1 - Participant Start", milestone_date: Date.new(2021, 10, 31), payment_date: Date.new(2021, 11, 30) },
  { name: "Output 2 – Retention Point 1", milestone_date: Date.new(2022, 1, 31), payment_date: Date.new(2022, 2, 28) },
  { name: "Output 3 – Retention Point 2", milestone_date: Date.new(2022, 4, 30), payment_date: Date.new(2022, 5, 31) },
  { name: "Output 4 – Retention Point 3", milestone_date: Date.new(2022, 9, 30), payment_date: Date.new(2022, 10, 31) },
  { name: "Output 5 – Retention Point 4", milestone_date: Date.new(2023, 1, 31), payment_date: Date.new(2023, 2, 28) },
  { name: "Output 6 – Participant Completion", milestone_date: Date.new(2023, 4, 30), payment_date: Date.new(2023, 5, 31) },
].each do |hash|
  Milestone.find_or_create_by!(
    schedule: ecf_september_standard_2021,
    name: hash[:name],
    milestone_date: hash[:milestone_date],
    payment_date: hash[:payment_date],
  )
end

ecf_september_extended_2021 = Schedule.find_or_create_by!(name: "ECF September extended 2021")
[
  { name: "Output 1 - Participant Start", milestone_date: Date.new(2021, 10, 31), payment_date: Date.new(2021, 11, 30) },
  { name: "Output 2 – Retention Point 1", milestone_date: Date.new(2022, 4, 30), payment_date: Date.new(2022, 5, 31) },
  { name: "Output 3 – Retention Point 2", milestone_date: Date.new(2022, 9, 30), payment_date: Date.new(2022, 10, 31) },
  { name: "Output 4 – Retention Point 3", milestone_date: Date.new(2023, 4, 30), payment_date: Date.new(2023, 5, 31) },
  { name: "Output 5 – Retention Point 4", milestone_date: Date.new(2023, 10, 31), payment_date: Date.new(2023, 11, 30) },
  { name: "Output 6 – Participant Completion", milestone_date: Date.new(2024, 4, 30), payment_date: Date.new(2024, 5, 31) },
].each do |hash|
  Milestone.find_or_create_by!(
    schedule: ecf_september_extended_2021,
    name: hash[:name],
    milestone_date: hash[:milestone_date],
    payment_date: hash[:payment_date],
  )
end

ecf_january_reduced_2022 = Schedule.find_or_create_by!(name: "ECF January reduced 2022")
[
  { name: "Output 1 - Participant Start", milestone_date: Date.new(2022, 1, 31), payment_date: Date.new(2022, 2, 28) },
  { name: "Output 2 and 3 – Retention Point 1 and 2", milestone_date: Date.new(2022, 4, 30), payment_date: Date.new(2022, 5, 31) },
  { name: "Output 4 – Retention Point 3", milestone_date: Date.new(2022, 9, 30), payment_date: Date.new(2022, 10, 31) },
  { name: "Output 5 – Retention Point 4", milestone_date: Date.new(2023, 1, 31), payment_date: Date.new(2023, 2, 28) },
  { name: "Output 6 – Participant Completion", milestone_date: Date.new(2023, 4, 30), payment_date: Date.new(2023, 5, 31) },
].each do |hash|
  Milestone.find_or_create_by!(
    schedule: ecf_january_reduced_2022,
    name: hash[:name],
    milestone_date: hash[:milestone_date],
    payment_date: hash[:payment_date],
  )
end

ecf_january_extended_2022 = Schedule.find_or_create_by!(name: "ECF January extended 2021")
[
  { name: "Output 1 - Participant Start", milestone_date: Date.new(2022, 1, 31), payment_date: Date.new(2022, 2, 28) },
  { name: "Output 2 and 3 – Retention Point 1 and 2", milestone_date: Date.new(2022, 9, 30), payment_date: Date.new(2022, 10, 31) },
  { name: "Output 4 – Retention Point 3", milestone_date: Date.new(2023, 4, 30), payment_date: Date.new(2023, 5, 31) },
  { name: "Output 5 – Retention Point 4", milestone_date: Date.new(2023, 10, 31), payment_date: Date.new(2023, 11, 30) },
  { name: "Output 6 – Participant Completion", milestone_date: Date.new(2024, 4, 30), payment_date: Date.new(2024, 5, 31) },
].each do |hash|
  Milestone.find_or_create_by!(
    schedule: ecf_january_extended_2022,
    name: hash[:name],
    milestone_date: hash[:milestone_date],
    payment_date: hash[:payment_date],
  )
end
