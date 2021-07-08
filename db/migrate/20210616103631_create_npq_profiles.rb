# frozen_string_literal: true

class CreateNPQProfiles < ActiveRecord::Migration[6.1]
  def change
    create_table :npq_profiles do |t|
      t.references :user
      t.references :npq_lead_provider
      t.references :npq_course

      t.date :date_of_birth
      t.text :teacher_reference_number
      t.boolean :teacher_reference_number_verified, default: false
      t.text :school_urn
      t.text :headteacher_status # no, yes_in_first_two_years, yes_over_two_years

      t.timestamps
    end
  end
end
