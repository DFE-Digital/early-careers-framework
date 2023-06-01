# frozen_string_literal: true

class UpdateTrainingRecordStatesToVersion2 < ActiveRecord::Migration[6.1]
  def change
    update_view :training_record_states, materialized: true, version: 2, revert_to_version: 1
  end
end
