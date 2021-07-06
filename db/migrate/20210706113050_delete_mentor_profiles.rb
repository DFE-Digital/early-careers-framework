# frozen_string_literal: true

class DeleteMentorProfiles < ActiveRecord::Migration[6.1]
  def up
    drop_table :mentor_profiles
  end

  def down
    create_table "mentor_profiles", id: :uuid do |t|
      t.uuid "user_id", null: false
      t.uuid "school_id", null: false
      t.uuid "core_induction_programme_id"
      t.uuid "cohort_id"
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
      t.boolean "sparsity_uplift", default: false, null: false
      t.boolean "pupil_premium_uplift", default: false, null: false
      t.index %w[cohort_id], name: "index_mentor_profiles_on_cohort_id"
      t.index %w[core_induction_programme_id], name: "index_mentor_profiles_on_core_induction_programme_id"
      t.index %w[school_id], name: "index_mentor_profiles_on_school_id"
      t.index %w[user_id], name: "index_mentor_profiles_on_user_id"
    end

    add_foreign_key "mentor_profiles", "cohorts"
    add_foreign_key "mentor_profiles", "core_induction_programmes"
    add_foreign_key "mentor_profiles", "schools"
    add_foreign_key "mentor_profiles", "users"
  end
end
