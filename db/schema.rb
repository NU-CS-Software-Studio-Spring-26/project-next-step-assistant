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

ActiveRecord::Schema[8.1].define(version: 2026_06_08_160000) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_db_files", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.binary "data", null: false
    t.string "key", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_active_storage_db_files_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "jobs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "deadline"
    t.text "description"
    t.string "organization_name"
    t.bigint "resume_id"
    t.string "source"
    t.date "start_date"
    t.string "status"
    t.string "title"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["resume_id"], name: "index_jobs_on_resume_id"
    t.index ["user_id", "deadline"], name: "index_jobs_on_user_id_and_deadline"
    t.index ["user_id", "status"], name: "index_jobs_on_user_id_and_status"
    t.index ["user_id"], name: "index_jobs_on_user_id"
    t.check_constraint "description IS NULL OR length(description) <= 5000", name: "jobs_description_max_length"
    t.check_constraint "length(organization_name) <= 200", name: "jobs_organization_name_max_length"
    t.check_constraint "length(title) <= 200", name: "jobs_title_max_length"
    t.check_constraint "status IN ('saved','applied','interviewing','offer','accepted','rejected','withdrawn')", name: "jobs_status_allowed"
  end

  create_table "projects", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "github_link"
    t.string "name"
    t.string "skills"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_projects_on_user_id"
    t.check_constraint "description IS NULL OR length(description) <= 5000", name: "projects_description_max_length"
    t.check_constraint "github_link IS NULL OR length(github_link) <= 2048", name: "projects_github_link_max_length"
    t.check_constraint "length(name) <= 200", name: "projects_name_max_length"
    t.check_constraint "skills IS NULL OR length(skills) <= 255", name: "projects_skills_max_length"
  end

  create_table "resumes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id"
    t.string "name", default: "Resume", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["job_id"], name: "index_resumes_on_job_id"
    t.index ["user_id"], name: "index_resumes_on_user_id"
    t.check_constraint "length(name) <= 200", name: "resumes_name_max_length"
  end

  create_table "users", force: :cascade do |t|
    t.string "calendar_token"
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "password_set_at"
    t.string "provider"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.string "uid"
    t.datetime "updated_at", null: false
    t.index ["calendar_token"], name: "index_users_on_calendar_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["provider", "uid"], name: "index_users_on_provider_and_uid", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "jobs", "resumes"
  add_foreign_key "jobs", "users"
  add_foreign_key "projects", "users"
  add_foreign_key "resumes", "jobs"
  add_foreign_key "resumes", "users"
end
