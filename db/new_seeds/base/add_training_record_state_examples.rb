# frozen_string_literal: true

scenarios = NewSeeds::Scenarios::Participants::TrainingRecordStates.new
scenarios.methods.each do |scenario_name|
  next unless scenario_name.to_s.start_with?("mentor_") || scenario_name.to_s.start_with?("ect_")

  Rails.logger.debug("Creating TrainingRecordState scenario #{scenario_name}")
  scenarios.send scenario_name
end
