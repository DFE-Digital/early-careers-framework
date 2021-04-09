# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_04_07_113051) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "admin_profiles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_admin_profiles_on_user_id"
  end

  create_table "cohorts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "start_year", limit: 2, null: false
  end

  create_table "core_induction_programmes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "course_year_one_id"
    t.uuid "course_year_two_id"
    t.index ["course_year_one_id"], name: "index_core_induction_programmes_on_course_year_one_id"
    t.index ["course_year_two_id"], name: "index_core_induction_programmes_on_course_year_two_id"
  end

  create_table "course_lesson_parts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "title", null: false
    t.text "content", null: false
    t.uuid "previous_lesson_part_id"
    t.uuid "course_lesson_id", null: false
    t.index ["course_lesson_id"], name: "index_course_lesson_parts_on_course_lesson_id"
    t.index ["previous_lesson_part_id"], name: "index_course_lesson_parts_on_previous_lesson_part_id"
  end

  create_table "course_lesson_progresses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "progress", default: "not_started"
    t.uuid "early_career_teacher_profile_id", null: false
    t.uuid "course_lesson_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["course_lesson_id", "early_career_teacher_profile_id"], name: "idx_cl_progresses_on_cl_id_and_ect_profile_id", unique: true
    t.index ["course_lesson_id"], name: "idx_course_lesson_progresses_on_course_lesson_id"
    t.index ["early_career_teacher_profile_id"], name: "idx_course_lesson_progresses_on_ect_profile_id"
  end

  create_table "course_lessons", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "title", null: false
    t.uuid "previous_lesson_id"
    t.uuid "course_module_id", null: false
    t.integer "version", default: 1, null: false
    t.integer "completion_time_in_minutes"
    t.index ["course_module_id"], name: "index_course_lessons_on_course_module_id"
    t.index ["previous_lesson_id"], name: "index_course_lessons_on_previous_lesson_id"
  end

  create_table "course_modules", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "title", null: false
    t.text "content", null: false
    t.uuid "previous_module_id"
    t.uuid "course_year_id", null: false
    t.integer "version", default: 1, null: false
    t.string "term", default: "spring"
    t.index ["course_year_id"], name: "index_course_modules_on_course_year_id"
    t.index ["previous_module_id"], name: "index_course_modules_on_previous_module_id"
  end

  create_table "course_years", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "title", null: false
    t.text "content", null: false
    t.integer "version", default: 1, null: false
  end

  create_table "delayed_jobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.string "cron"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "early_career_teacher_profiles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "core_induction_programme_id"
    t.uuid "cohort_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "mentor_profile_id"
    t.index ["cohort_id"], name: "index_early_career_teacher_profiles_on_cohort_id"
    t.index ["core_induction_programme_id"], name: "index_ect_profiles_on_core_induction_programme_id"
    t.index ["mentor_profile_id"], name: "index_early_career_teacher_profiles_on_mentor_profile_id"
    t.index ["user_id"], name: "index_early_career_teacher_profiles_on_user_id"
  end

  create_table "induction_coordinator_profiles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_induction_coordinator_profiles_on_user_id"
  end

  create_table "mentor_profiles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_mentor_profiles_on_user_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "full_name", null: false
    t.string "email", default: "", null: false
    t.string "login_token"
    t.datetime "login_token_valid_until"
    t.datetime "remember_created_at"
    t.datetime "last_sign_in_at"
    t.datetime "current_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.integer "sign_in_count", default: 0, null: false
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "username"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "admin_profiles", "users"
  add_foreign_key "core_induction_programmes", "course_years", column: "course_year_one_id"
  add_foreign_key "core_induction_programmes", "course_years", column: "course_year_two_id"
  add_foreign_key "course_lesson_parts", "course_lesson_parts", column: "previous_lesson_part_id"
  add_foreign_key "course_lesson_parts", "course_lessons"
  add_foreign_key "course_lesson_progresses", "course_lessons"
  add_foreign_key "course_lesson_progresses", "early_career_teacher_profiles"
  add_foreign_key "course_lessons", "course_lessons", column: "previous_lesson_id"
  add_foreign_key "course_lessons", "course_modules"
  add_foreign_key "course_modules", "course_modules", column: "previous_module_id"
  add_foreign_key "course_modules", "course_years"
  add_foreign_key "early_career_teacher_profiles", "cohorts"
  add_foreign_key "early_career_teacher_profiles", "core_induction_programmes"
  add_foreign_key "early_career_teacher_profiles", "mentor_profiles"
  add_foreign_key "early_career_teacher_profiles", "users"
  add_foreign_key "induction_coordinator_profiles", "users"
  add_foreign_key "mentor_profiles", "users"
end
