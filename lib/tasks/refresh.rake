# frozen_string_literal: true

namespace :refresh do
  desc "Refresh materialized view for Training Record States"
  task training_record_states: :environment do
    TrainingRecordState.refresh
  end
end
