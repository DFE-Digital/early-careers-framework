# frozen_string_literal: true

class DropTrainingRecordStatesMaterializedView < ActiveRecord::Migration[6.1]
  def change
    drop_view :training_record_states, materialized: true
  end
end
