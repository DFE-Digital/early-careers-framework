# frozen_string_literal: true

Importers::CreateCohort.new(path_to_csv: Rails.root.join("db/data/cohorts/cohorts.csv")).call

ActiveRecord::Base.transaction do
  Importers::CreateSchedule.new(path_to_csv: Rails.root.join("db/data/schedules/schedules.csv")).call
end
