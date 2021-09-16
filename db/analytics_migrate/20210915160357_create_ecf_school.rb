# frozen_string_literal: true

class CreateECFSchool < ActiveRecord::Migration[6.1]
  def change
    create_table :ecf_schools do |t|
      t.string :name
      t.string :urn
      t.datetime :nomination_email_opened_at
      t.boolean :induction_tutor_nominated
      t.datetime :tutor_nominated_time
      t.boolean :induction_tutor_signed_in
      t.string :induction_programme_choice
      t.boolean :in_partnership
      t.datetime :partnership_time
      t.string :partnership_challenge_reason
      t.string :partnership_challenge_time
      t.string :lead_provider
      t.string :delivery_partner
      t.string :chosen_cip
    end

    add_index :ecf_schools, :urn, unique: true
  end
end
