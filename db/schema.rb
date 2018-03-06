# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170506180055) do

  create_table "allocation_configs", force: :cascade do |t|
    t.float   "alpha_ability_difference"
    t.float   "alpha_different_tutor"
    t.integer "hard_iterations_limit"
    t.integer "no_improvement_stop"
    t.integer "tabu_queue_size"
  end

  create_table "allocation_jobs", force: :cascade do |t|
    t.integer  "author_id"
    t.integer  "project_id"
    t.integer  "status",       default: 0
    t.datetime "failed_at"
    t.datetime "completed_at"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.index ["author_id"], name: "index_allocation_jobs_on_author_id"
    t.index ["project_id"], name: "index_allocation_jobs_on_project_id"
  end

  create_table "course_years", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "courses", force: :cascade do |t|
    t.string   "name"
    t.string   "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "groups", force: :cascade do |t|
    t.integer  "tutor_id"
    t.integer  "project_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_groups_on_project_id"
    t.index ["tutor_id"], name: "index_groups_on_tutor_id"
  end

  create_table "groups_students", id: false, force: :cascade do |t|
    t.integer "group_id",   null: false
    t.integer "student_id", null: false
  end

  create_table "holding_pen_groups", force: :cascade do |t|
    t.integer  "project_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_holding_pen_groups_on_project_id"
  end

  create_table "holding_pen_reviews", force: :cascade do |t|
    t.integer  "review_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["review_id"], name: "index_holding_pen_reviews_on_review_id"
  end

  create_table "holding_pen_reviews_students", id: false, force: :cascade do |t|
    t.integer "holding_pen_review_id", null: false
    t.integer "student_id",            null: false
  end

  create_table "holding_pens", force: :cascade do |t|
    t.integer  "project_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_holding_pens_on_project_id"
  end

  create_table "holding_pens_students", id: false, force: :cascade do |t|
    t.integer "holding_pen_id", null: false
    t.integer "student_id",     null: false
  end

  create_table "projects", force: :cascade do |t|
    t.string   "name"
    t.integer  "course_year_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.integer  "num_review_periods"
    t.index ["course_year_id"], name: "index_projects_on_course_year_id"
  end

  create_table "review_groups", force: :cascade do |t|
    t.integer  "tutor_id"
    t.integer  "review_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["review_id"], name: "index_review_groups_on_review_id"
    t.index ["tutor_id"], name: "index_review_groups_on_tutor_id"
  end

  create_table "review_groups_students", id: false, force: :cascade do |t|
    t.integer "review_group_id", null: false
    t.integer "student_id",      null: false
  end

  create_table "reviews", force: :cascade do |t|
    t.integer "project_id"
    t.index ["project_id"], name: "index_reviews_on_project_id"
  end

  create_table "reviews_students", id: false, force: :cascade do |t|
    t.integer "review_id",  null: false
    t.integer "student_id", null: false
  end

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "students", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.integer  "registration_number"
    t.string   "email"
    t.integer  "ability"
    t.boolean  "overseas"
    t.integer  "course_year_id"
    t.integer  "course_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.index ["course_id"], name: "index_students_on_course_id"
    t.index ["course_year_id"], name: "index_students_on_course_year_id"
  end

  create_table "tutors", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.integer  "course_year_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.index ["course_year_id"], name: "index_tutors_on_course_year_id"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "allocation_config_id"
    t.integer  "course_year_id"
    t.index ["allocation_config_id"], name: "index_users_on_allocation_config_id"
    t.index ["course_year_id"], name: "index_users_on_course_year_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
