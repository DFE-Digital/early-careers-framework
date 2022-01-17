# frozen_string_literal: true

class AddScheduleIdentifierToECFParticipant < ActiveRecord::Migration[6.1]
  def change
    add_column :ecf_participants, :schedule_identifier, :boolean, default: true
  end
end
