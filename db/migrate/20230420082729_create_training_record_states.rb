# frozen_string_literal: true

class CreateTrainingRecordStates < ActiveRecord::Migration[6.1]
  def change
    create_view :training_record_states, materialized: true
  end
end
