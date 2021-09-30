# frozen_string_literal: true

class AddUrnUkprnToParticipantProfiles < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      change_table :participant_profiles, bulk: true do |t|
        t.column :school_urn, :text, null: true
        t.column :school_ukprn, :text, null: true
      end
    end
  end
end
