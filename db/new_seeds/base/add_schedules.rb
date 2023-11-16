# frozen_string_literal: true

Rails.logger.info("Importing schedules")

Importers::CreateSchedule.new(path_to_csv: Rails.root.join("db/data/schedules/schedules.csv")).call

# Ensure Cohort.next always has NPQ schedules that can be used
if Finance::Schedule.find_by(cohort: Cohort.next, schedule_identifier: "npq-ehco-november").nil?
  next_start_year = Cohort.next.start_year
  csv = Tempfile.new("data.csv")

  csv.write "type,schedule-identifier,schedule-name,schedule-cohort-year,milestone-name,milestone-declaration-type,milestone-start-date,milestone-date,milestone-payment-date"
  csv.write "\n"

  csv.write "npq_ehco,npq-ehco-november,NPQ EHCO November,#{next_start_year},Output 1 - Participant Start,started,01/11/#{next_start_year},,01/11/#{next_start_year}"
  csv.write "npq_ehco,npq-ehco-november,NPQ EHCO November,#{next_start_year},Output 2 - Retention Point 1,retained-1,01/11/#{next_start_year},,01/11/#{next_start_year}"
  csv.write "npq_ehco,npq-ehco-november,NPQ EHCO November,#{next_start_year},Output 3 - Retention Point 2,retained-2,01/11/#{next_start_year},,01/11/#{next_start_year}"
  csv.write "npq_ehco,npq-ehco-november,NPQ EHCO November,#{next_start_year},Output 4 - Participant Completion,completed,01/11/#{next_start_year},,01/11/#{next_start_year}"

  csv.close

  Importers::CreateSchedule.new(path_to_csv: csv.path).call
end

if Finance::Schedule.find_by(cohort: Cohort.next, schedule_identifier: "npq-ehco-december").nil?
  next_start_year = Cohort.next.start_year
  csv = Tempfile.new("data.csv")

  csv.write "type,schedule-identifier,schedule-name,schedule-cohort-year,milestone-name,milestone-declaration-type,milestone-start-date,milestone-date,milestone-payment-date"
  csv.write "\n"

  csv.write "npq_ehco,npq-ehco-december,NPQ EHCO December,#{next_start_year},Output 1 - Participant Start,started,01/12/#{next_start_year},,01/12/#{next_start_year}"
  csv.write "npq_ehco,npq-ehco-december,NPQ EHCO December,#{next_start_year},Output 2 - Retention Point 1,retained-1,01/12/#{next_start_year},,01/12/#{next_start_year}"
  csv.write "npq_ehco,npq-ehco-december,NPQ EHCO December,#{next_start_year},Output 3 - Retention Point 2,retained-2,01/12/#{next_start_year},,01/12/#{next_start_year}"
  csv.write "npq_ehco,npq-ehco-december,NPQ EHCO December,#{next_start_year},Output 4 - Participant Completion,completed,01/12/#{next_start_year},,01/12/#{next_start_year}"

  csv.close

  Importers::CreateSchedule.new(path_to_csv: csv.path).call
end

if Finance::Schedule.find_by(cohort: Cohort.next, schedule_identifier: "npq-ehco-march").nil?
  next_start_year = Cohort.next.start_year
  csv = Tempfile.new("data.csv")

  csv.write "type,schedule-identifier,schedule-name,schedule-cohort-year,milestone-name,milestone-declaration-type,milestone-start-date,milestone-date,milestone-payment-date"
  csv.write "\n"

  csv.write "npq_ehco,npq-ehco-march,NPQ EHCO March,#{next_start_year},Output 1 - Participant Start,started,01/03/#{next_start_year + 1},,01/03/#{next_start_year + 1}"
  csv.write "npq_ehco,npq-ehco-march,NPQ EHCO March,#{next_start_year},Output 2 - Retention Point 1,retained-1,01/03/#{next_start_year + 1},,01/03/#{next_start_year + 1}"
  csv.write "npq_ehco,npq-ehco-march,NPQ EHCO March,#{next_start_year},Output 3 - Retention Point 2,retained-2,01/03/#{next_start_year + 1},,01/03/#{next_start_year + 1}"
  csv.write "npq_ehco,npq-ehco-march,NPQ EHCO March,#{next_start_year},Output 4 - Participant Completion,completed,01/03/#{next_start_year + 1},,01/03/#{next_start_year + 1}"

  csv.close

  Importers::CreateSchedule.new(path_to_csv: csv.path).call
end

if Finance::Schedule.find_by(cohort: Cohort.next, schedule_identifier: "npq-ehco-june").nil?
  next_start_year = Cohort.next.start_year
  csv = Tempfile.new("data.csv")

  csv.write "type,schedule-identifier,schedule-name,schedule-cohort-year,milestone-name,milestone-declaration-type,milestone-start-date,milestone-date,milestone-payment-date"
  csv.write "\n"

  csv.write "npq_ehco,npq-ehco-june,NPQ EHCO June,#{next_start_year},Output 1 - Participant Start,started,01/06/#{next_start_year + 1},,01/06/#{next_start_year + 1}"
  csv.write "npq_ehco,npq-ehco-june,NPQ EHCO June,#{next_start_year},Output 2 - Retention Point 1,retained-1,01/06/#{next_start_year + 1},,01/06/#{next_start_year + 1}"
  csv.write "npq_ehco,npq-ehco-june,NPQ EHCO June,#{next_start_year},Output 3 - Retention Point 2,retained-2,01/06/#{next_start_year + 1},,01/06/#{next_start_year + 1}"
  csv.write "npq_ehco,npq-ehco-june,NPQ EHCO June,#{next_start_year},Output 4 - Participant Completion,completed,01/06/#{next_start_year + 1},,01/06/#{next_start_year + 1}"

  csv.close

  Importers::CreateSchedule.new(path_to_csv: csv.path).call
end

if Finance::Schedule.find_by(cohort: Cohort.next, schedule_identifier: "npq-leadership-autumn").nil?
  next_start_year = Cohort.next.start_year
  csv = Tempfile.new("data.csv")

  csv.write "type,schedule-identifier,schedule-name,schedule-cohort-year,milestone-name,milestone-declaration-type,milestone-start-date,milestone-date,milestone-payment-date"
  csv.write "\n"

  csv.write "npq_leadership,npq-leadership-autumn,NPQ Leadership Autumn,#{next_start_year},Output 1 - Participant Start,started,01/11/#{next_start_year},,01/11/#{next_start_year}"
  csv.write "npq_leadership,npq-leadership-autumn,NPQ Leadership Autumn,#{next_start_year},Output 2 - Retention Point 1,retained-1,01/11/#{next_start_year},,01/11/#{next_start_year}"
  csv.write "npq_leadership,npq-leadership-autumn,NPQ Leadership Autumn,#{next_start_year},Output 3 - Retention Point 2,retained-2,01/11/#{next_start_year},,01/11/#{next_start_year}"
  csv.write "npq_leadership,npq-leadership-autumn,NPQ Leadership Autumn,#{next_start_year},Output 4 - Participant Completion,completed,01/11/#{next_start_year},,01/11/#{next_start_year}"

  csv.close

  Importers::CreateSchedule.new(path_to_csv: csv.path).call
end

if Finance::Schedule.find_by(cohort: Cohort.next, schedule_identifier: "npq-leadership-spring").nil?
  next_start_year = Cohort.next.start_year
  csv = Tempfile.new("data.csv")

  csv.write "type,schedule-identifier,schedule-name,schedule-cohort-year,milestone-name,milestone-declaration-type,milestone-start-date,milestone-date,milestone-payment-date"
  csv.write "\n"

  csv.write "npq_leadership,npq-leadership-spring,NPQ Leadership Spring,#{next_start_year},Output 1 - Participant Start,started,01/01/#{next_start_year + 1},,01/01/#{next_start_year + 1}"
  csv.write "npq_leadership,npq-leadership-spring,NPQ Leadership Spring,#{next_start_year},Output 2 - Retention Point 1,retained-1,01/01/#{next_start_year + 1},,01/01/#{next_start_year + 1}"
  csv.write "npq_leadership,npq-leadership-spring,NPQ Leadership Spring,#{next_start_year},Output 3 - Retention Point 2,retained-2,01/01/#{next_start_year + 1},,01/01/#{next_start_year + 1}"
  csv.write "npq_leadership,npq-leadership-spring,NPQ Leadership Spring,#{next_start_year},Output 4 - Participant Completion,completed,01/01/#{next_start_year + 1},,01/01/#{next_start_year + 1}"

  csv.close

  Importers::CreateSchedule.new(path_to_csv: csv.path).call
end

if Finance::Schedule.find_by(cohort: Cohort.next, schedule_identifier: "npq-specialist-autumn").nil?
  next_start_year = Cohort.next.start_year
  csv = Tempfile.new("data.csv")

  csv.write "type,schedule-identifier,schedule-name,schedule-cohort-year,milestone-name,milestone-declaration-type,milestone-start-date,milestone-date,milestone-payment-date"
  csv.write "\n"

  csv.write "npq_specialist,npq-specialist-autumn,NPQ Specialist Autumn,#{next_start_year},Output 1 - Participant Start,started,01/11/#{next_start_year},,01/11/#{next_start_year}"
  csv.write "npq_specialist,npq-specialist-autumn,NPQ Specialist Autumn,#{next_start_year},Output 2 - Retention Point 1,retained-1,01/11/#{next_start_year},,01/11/#{next_start_year}"
  csv.write "npq_specialist,npq-specialist-autumn,NPQ Specialist Autumn,#{next_start_year},Output 3 - Participant Completion,completed,01/11/#{next_start_year},,01/11/#{next_start_year}"

  csv.close

  Importers::CreateSchedule.new(path_to_csv: csv.path).call
end

if Finance::Schedule.find_by(cohort: Cohort.next, schedule_identifier: "npq-specialist-spring").nil?
  next_start_year = Cohort.next.start_year
  csv = Tempfile.new("data.csv")

  csv.write "type,schedule-identifier,schedule-name,schedule-cohort-year,milestone-name,milestone-declaration-type,milestone-start-date,milestone-date,milestone-payment-date"
  csv.write "\n"

  csv.write "npq_specialist,npq-specialist-spring,NPQ Specialist Spring,#{next_start_year},Output 1 - Participant Start,started,01/01/#{next_start_year + 1},,01/01/#{next_start_year + 1}"
  csv.write "npq_specialist,npq-specialist-spring,NPQ Specialist Spring,#{next_start_year},Output 2 - Retention Point 1,retained-1,01/01/#{next_start_year + 1},,01/01/#{next_start_year + 1}"
  csv.write "npq_specialist,npq-specialist-spring,NPQ Specialist Spring,#{next_start_year},Output 3 - Participant Completion,completed,01/01/#{next_start_year + 1},,01/01/#{next_start_year + 1}"

  csv.close

  Importers::CreateSchedule.new(path_to_csv: csv.path).call
end
