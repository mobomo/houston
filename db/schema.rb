# encoding: UTF-8
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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20140220230907) do

  create_table "announcements", :force => true do |t|
    t.string   "text"
    t.integer  "user_id"
    t.string   "category"
    t.date     "date"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "comments", :force => true do |t|
    t.integer  "week_hour_id"
    t.text     "text"
    t.integer  "seq"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.integer  "project_id"
    t.integer  "row"
    t.integer  "col"
    t.time     "deleted_at"
    t.integer  "year"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "doc_auths", :force => true do |t|
    t.string   "key"
    t.string   "username"
    t.string   "password"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.boolean  "current"
  end

  create_table "experiences", :force => true do |t|
    t.integer  "level"
    t.string   "notes"
    t.integer  "skill_id"
    t.integer  "user_id"
    t.float    "years"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.boolean  "display",        :default => false
    t.string   "from"
    t.text     "cc"
    t.text     "message"
    t.text     "ending_content"
  end

  create_table "imports", :force => true do |t|
    t.datetime "start_at"
    t.datetime "end_at"
    t.boolean  "success"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.boolean  "manual",     :default => false
  end

  create_table "leave_requests", :force => true do |t|
    t.integer  "user_id"
    t.integer  "approved_by"
    t.datetime "start_date"
    t.datetime "end_date"
    t.boolean  "approved"
    t.datetime "approved_date"
    t.text     "reason_for_leaving"
    t.text     "checked_with_supervisor"
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  create_table "milestones", :force => true do |t|
    t.date     "date"
    t.text     "notes"
    t.integer  "project_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "milestones", ["project_id"], :name => "index_milestones_on_project_id"

  create_table "projects", :force => true do |t|
    t.string   "client"
    t.string   "name"
    t.date     "date_signed"
    t.date     "date_kickoff"
    t.date     "date_target"
    t.date     "date_delivered"
    t.boolean  "is_confirmed",     :default => false
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.boolean  "is_delivered",     :default => false
    t.string   "status"
    t.string   "hours_budget"
    t.string   "hours_used"
    t.float    "rate"
    t.text     "comment"
    t.string   "url_pmtool"
    t.string   "url_demo"
    t.float    "percent_complete"
    t.time     "deleted_at"
    t.string   "project_manager"
  end

  create_table "raw_items", :force => true do |t|
    t.string  "status"
    t.integer "user_id"
    t.string  "client"
    t.string  "project"
    t.string  "skill"
    t.boolean "billable"
    t.string  "user_name"
    t.string  "row"
    t.integer "project_id"
    t.time    "deleted_at"
  end

  create_table "required_skills", :force => true do |t|
    t.integer  "level"
    t.string   "notes"
    t.integer  "skill_id"
    t.integer  "project_id"
    t.float    "years"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "schedules", :force => true do |t|
    t.integer  "user_id"
    t.text     "message"
    t.text     "gdata_content"
    t.datetime "week_start"
    t.datetime "week_end"
    t.string   "status"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.string   "cc"
    t.string   "from"
    t.text     "ending_content"
    t.text     "daily_schedule"
  end

  create_table "settings", :force => true do |t|
    t.string   "var",                      :null => false
    t.text     "value"
    t.integer  "thing_id"
    t.string   "thing_type", :limit => 30
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  add_index "settings", ["thing_type", "thing_id", "var"], :name => "index_settings_on_thing_type_and_thing_id_and_var", :unique => true

  create_table "skills", :force => true do |t|
    t.string   "name"
    t.integer  "importance"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.boolean  "is_pm"
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
    t.string   "uid"
    t.string   "provider"
    t.string   "domain"
    t.boolean  "status"
    t.integer  "group_id"
    t.string   "role",                  :default => "Regular"
    t.string   "harvest_token"
    t.string   "harvest_refresh_token"
    t.datetime "expires_at"
    t.datetime "refresh_at"
    t.datetime "logged_in"
  end

  create_table "versions", :force => true do |t|
    t.string   "item_type",      :null => false
    t.integer  "item_id",        :null => false
    t.string   "event",          :null => false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
    t.string   "object_changes"
  end

  add_index "versions", ["item_type", "item_id"], :name => "index_versions_on_item_type_and_item_id"

  create_table "week_hours", :force => true do |t|
    t.integer  "raw_item_id"
    t.string   "hours"
    t.datetime "week"
    t.integer  "user_id"
  end

end
