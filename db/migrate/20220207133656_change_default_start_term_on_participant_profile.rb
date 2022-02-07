# frozen_string_literal: true

class ChangeDefaultStartTermOnParticipantProfile < ActiveRecord::Migration[6.1]
  def change
    change_column_default :participant_profiles, :start_term, from: "Autumn 2021", to: "autumn_2021"
  end
end
