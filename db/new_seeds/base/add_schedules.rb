# frozen_string_literal: true

{
  "db/data/schedules/npq_specialist.csv" => Finance::Schedule::NPQSpecialist,
  "db/data/schedules/npq_leadership.csv" => Finance::Schedule::NPQLeadership,
  "db/data/schedules/npq_aso.csv" => Finance::Schedule::NPQSupport,
  "db/data/schedules/npq_ehco.csv" => Finance::Schedule::NPQEhco,
  "db/data/schedules/ecf_standard.csv" => Finance::Schedule::ECF,
  "db/data/schedules/ecf_reduced.csv" => Finance::Schedule::ECF,
  "db/data/schedules/ecf_extended.csv" => Finance::Schedule::ECF,
  "db/data/schedules/ecf_replacement.csv" => Finance::Schedule::Mentor,
}.each do |file, klass|
  path_to_csv = Rails.root.join(file)

  Rails.logger.info("importing '#{file}'")

  Importers::SeedSchedule.new(klass:, path_to_csv:).call
end
