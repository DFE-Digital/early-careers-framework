# frozen_string_literal: true

Rails.logger.info("Importing schedules")

Importers::CreateSchedule.new(path_to_csv: Rails.root.join("db/data/schedules/schedules.csv")).call
