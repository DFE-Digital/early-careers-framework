# frozen_string_literal: true

class ChangeScheduleIdentifierType < ActiveRecord::Migration[6.1]
  def up
    safety_assured { change_column_default :ecf_participants, :schedule_identifier, from: true, to: nil }
    safety_assured { change_column :ecf_participants, :schedule_identifier, :string }
  end

  def down
    safety_assured { change_column :ecf_participants, :schedule_identifier, "boolean USING CAST(schedule_identifier AS boolean)" }
    safety_assured { change_column_default :ecf_participants, :schedule_identifier, from: nil, to: true }
  end
end
