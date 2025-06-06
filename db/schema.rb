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

ActiveRecord::Schema[8.0].define(version: 2025_04_20_180923) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "booking_slots", force: :cascade do |t|
    t.bigint "booking_id", null: false
    t.datetime "start_time", null: false
    t.datetime "end_time", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "complete", default: false
    t.index ["booking_id", "start_time", "end_time"], name: "index_booking_slots_on_booking_id_and_start_time_and_end_time"
    t.index ["booking_id"], name: "index_booking_slots_on_booking_id"
    t.index ["start_time", "end_time"], name: "index_booking_slots_on_start_time_and_end_time"
  end

  create_table "bookings", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "room_id", null: false
    t.datetime "start_time"
    t.datetime "end_time"
    t.boolean "complete"
    t.string "confirmation_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.text "description"
    t.integer "expected_participants"
    t.index ["room_id"], name: "index_bookings_on_room_id"
    t.index ["user_id"], name: "index_bookings_on_user_id"
  end

  create_table "check_ins", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "booking_id", null: false
    t.datetime "check_in"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "confirmation_code"
    t.bigint "booking_slot_id", null: false
    t.index ["booking_id"], name: "index_check_ins_on_booking_id"
    t.index ["booking_slot_id"], name: "index_check_ins_on_booking_slot_id"
    t.index ["user_id"], name: "index_check_ins_on_user_id"
  end

  create_table "meeting_participants", force: :cascade do |t|
    t.bigint "booking_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["booking_id", "user_id"], name: "index_meeting_participants_on_booking_id_and_user_id", unique: true
    t.index ["booking_id"], name: "index_meeting_participants_on_booking_id"
    t.index ["user_id"], name: "index_meeting_participants_on_user_id"
  end

  create_table "room_qr_codes", force: :cascade do |t|
    t.bigint "room_id", null: false
    t.string "token", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["room_id"], name: "index_room_qr_codes_on_room_id"
    t.index ["token"], name: "index_room_qr_codes_on_token", unique: true
  end

  create_table "rooms", force: :cascade do |t|
    t.string "name"
    t.integer "capacity"
    t.string "description"
    t.integer "status_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "solid_queue_jobs", force: :cascade do |t|
    t.string "job_class"
    t.text "arguments"
    t.string "status", default: "pending"
    t.datetime "enqueued_at", precision: nil
    t.datetime "performed_at", precision: nil
    t.datetime "failed_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "statuses", force: :cascade do |t|
    t.string "status_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.string "email"
    t.string "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "avatar"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "booking_slots", "bookings"
  add_foreign_key "bookings", "rooms"
  add_foreign_key "bookings", "users"
  add_foreign_key "check_ins", "booking_slots"
  add_foreign_key "check_ins", "bookings"
  add_foreign_key "check_ins", "users"
  add_foreign_key "meeting_participants", "bookings"
  add_foreign_key "meeting_participants", "users"
  add_foreign_key "room_qr_codes", "rooms"
end
