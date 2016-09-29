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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160519062110) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"
  enable_extension "pgrouting"
  enable_extension "postgis_topology"
  enable_extension "kmeans"
  enable_extension "btree_gist"

  create_table "api_keys", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "access_token"
    t.datetime "deleted_at"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "api_keys", ["access_token"], name: "index_api_keys_on_access_token", unique: true, using: :btree
  add_index "api_keys", ["deleted_at"], name: "index_api_keys_on_deleted_at", using: :btree
  add_index "api_keys", ["user_id"], name: "index_api_keys_on_user_id", using: :btree

  create_table "cities", id: :bigserial, force: :cascade do |t|
    t.string    "name",                  limit: 255,                                                             null: false
    t.string    "state",                 limit: 255,                                                             null: false
    t.string    "country",               limit: 255,                                                             null: false
    t.float     "lower_left_lat",                                                                                null: false
    t.float     "lower_left_lng",                                                                                null: false
    t.float     "upper_right_lat",                                                                               null: false
    t.float     "upper_right_lng",                                                                               null: false
    t.string    "city_time_zone",        limit: 255
    t.boolean   "crime_day_time_report"
    t.text      "neighbour"
    t.geography "south_west",            limit: {:srid=>4326, :type=>"point", :geographic=>true}
    t.geography "north_east",            limit: {:srid=>4326, :type=>"point", :geographic=>true}
    t.geography "area",                  limit: {:srid=>0, :type=>"geometry"}
    t.boolean   "coming_soon",                                                                    default: true
    t.float     "grid_size"
    t.integer   "total_rows"
    t.integer   "total_cols"
  end

  add_index "cities", ["area"], name: "cities_area_gix", using: :gist
  add_index "cities", ["country", "state", "name"], name: "cities_country_state_city_idx", using: :btree
  add_index "cities", ["name"], name: "cities_city_idx", using: :btree

  create_table "cities_crime_type_weights", force: :cascade do |t|
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "city_id"
    t.integer  "crime_type_id"
    t.float    "crime_weight"
  end

  add_index "cities_crime_type_weights", ["city_id"], name: "index_cities_crime_type_weights_on_city_id", using: :btree
  add_index "cities_crime_type_weights", ["crime_type_id"], name: "index_cities_crime_type_weights_on_crime_type_id", using: :btree

  create_table "crime_data", id: :bigserial, force: :cascade do |t|
    t.string    "crime_case_id",             limit: 255,                                              null: false
    t.integer   "city_id",                   limit: 8,                                                null: false
    t.integer   "crime_type_id",             limit: 8
    t.datetime  "occurred_at",                                                                        null: false
    t.string    "time_zone",                 limit: 255,                                              null: false
    t.text      "note"
    t.float     "accuracy"
    t.datetime  "reported_at"
    t.string    "ucr",                       limit: 255
    t.boolean   "domestic"
    t.boolean   "arrested"
    t.float     "crime_weight"
    t.integer   "crime_day_time"
    t.string    "source",                    limit: 255,                                              null: false
    t.string    "source_url",                limit: 255
    t.string    "crime_picture_url",         limit: 255
    t.string    "crime_video_url",           limit: 255
    t.string    "address",                   limit: 255
    t.string    "beat",                      limit: 255
    t.string    "block",                     limit: 255
    t.string    "ward",                      limit: 255
    t.string    "community_area",            limit: 255
    t.string    "district",                  limit: 255
    t.string    "postcode",                  limit: 255
    t.text      "location_description"
    t.text      "description"
    t.geography "location",                  limit: {:srid=>4326, :type=>"point", :geographic=>true}, null: false
    t.string    "day_of_week",               limit: 255
    t.integer   "crime_type_description_id", limit: 8
  end

  add_index "crime_data", ["address"], name: "crime_data_address_idx", using: :btree
  add_index "crime_data", ["crime_case_id"], name: "crime_data_crime_case_id_idx", using: :btree
  add_index "crime_data", ["location"], name: "crime_data_location_gix", using: :gist
  add_index "crime_data", ["occurred_at"], name: "crime_data_occurred_at_idx", using: :btree
  add_index "crime_data", ["reported_at"], name: "crime_data_reported_at_idx", using: :btree
  add_index "crime_data", ["time_zone"], name: "crime_data_time_zone_idx", using: :btree

  create_table "crime_grids", force: :cascade do |t|
    t.integer  "city_id"
    t.integer  "row"
    t.integer  "col"
    t.geometry "area",                 limit: {:srid=>0, :type=>"polygon"}
    t.integer  "daytime_safety_level"
    t.integer  "dark_safety_level"
    t.datetime "created_at",                                                null: false
    t.datetime "updated_at",                                                null: false
  end

  add_index "crime_grids", ["city_id"], name: "index_crime_grids_on_city_id", using: :btree

  create_table "crime_streets_rating", primary_key: "crime_streets_id", force: :cascade do |t|
    t.string   "city",                           limit: 100
    t.string   "state",                          limit: 100
    t.string   "country",                        limit: 100
    t.string   "postcode",                       limit: 255, null: false
    t.integer  "avg_user_streets_safety_rating",             null: false
    t.string   "crime_streets_rating",           limit: 20,  null: false
    t.text     "grid_address"
    t.datetime "created_date"
    t.datetime "updated_date"
  end

  create_table "crime_type_descriptions", id: :bigserial, force: :cascade do |t|
    t.text     "description",                            null: false
    t.integer  "crime_type_id", limit: 8
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "review",                  default: true
  end

  create_table "crime_types", id: :bigserial, force: :cascade do |t|
    t.string   "name",               limit: 255, null: false
    t.float    "crime_weight",                   null: false
    t.text     "display_name"
    t.text     "description"
    t.boolean  "violent"
    t.integer  "subtype_of",         limit: 8
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "report_category_id"
  end

  add_index "crime_types", ["name"], name: "crime_types_crime_type_idx", using: :btree
  add_index "crime_types", ["report_category_id"], name: "index_crime_types_on_report_category_id", using: :btree

  create_table "external_auths", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "external_auths", ["provider", "uid"], name: "index_external_auths_on_provider_and_uid", unique: true, using: :btree
  add_index "external_auths", ["user_id", "provider"], name: "index_external_auths_on_user_id_and_provider", unique: true, using: :btree
  add_index "external_auths", ["user_id"], name: "index_external_auths_on_user_id", using: :btree

  create_table "features", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "total_votes"
    t.boolean  "completed",   default: false
    t.boolean  "archived",    default: false
    t.boolean  "notified",    default: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "features_users", force: :cascade do |t|
    t.integer  "features_id"
    t.integer  "users_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "notifications", force: :cascade do |t|
    t.string   "title"
    t.string   "error_msg"
    t.json     "error_code"
    t.boolean  "reviewed"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.boolean  "annual_report"
  end

  create_table "osm_2po_4pgr", force: :cascade do |t|
    t.integer  "osm_id",               limit: 8
    t.string   "osm_name"
    t.string   "osm_meta"
    t.integer  "osm_source_id",        limit: 8
    t.integer  "osm_target_id",        limit: 8
    t.integer  "clazz"
    t.integer  "flags"
    t.integer  "source"
    t.integer  "target"
    t.float    "km"
    t.integer  "kmh"
    t.float    "cost"
    t.float    "reverse_cost"
    t.float    "x1"
    t.float    "y1"
    t.float    "x2"
    t.float    "y2"
    t.geometry "geom_way",             limit: {:srid=>4326, :type=>"line_string"}
    t.integer  "daytime_safety_level"
    t.integer  "dark_safety_level"
    t.float    "daytime_cost"
    t.float    "dark_cost"
  end

  add_index "osm_2po_4pgr", ["geom_way"], name: "osm_2po_4pgr_geom_way_gix", using: :gist
  add_index "osm_2po_4pgr", ["source"], name: "idx_osm_2po_4pgr_source", using: :btree
  add_index "osm_2po_4pgr", ["target"], name: "idx_osm_2po_4pgr_target", using: :btree

  create_table "osm_2po_vertex", force: :cascade do |t|
    t.integer  "clazz"
    t.integer  "osm_id",       limit: 8
    t.string   "osm_name"
    t.integer  "ref_count"
    t.string   "restrictions"
    t.geometry "geom_vertex",  limit: {:srid=>4326, :type=>"point"}
  end

  add_index "osm_2po_vertex", ["geom_vertex"], name: "osm_2po_vertex_geom_way_gix", using: :gist
  add_index "osm_2po_vertex", ["osm_id"], name: "idx_osm_2po_vertex_osm_id", using: :btree

  create_table "pois", force: :cascade do |t|
    t.string   "name"
    t.integer  "city_id"
    t.geometry "location",         limit: {:srid=>0, :type=>"geometry"}
    t.string   "poi_safety_level"
    t.string   "address"
    t.datetime "created_at",                                             null: false
    t.datetime "updated_at",                                             null: false
    t.string   "poi_type"
  end

  create_table "report_categories", force: :cascade do |t|
    t.string   "name"
    t.string   "group_name"
    t.string   "description"
    t.float    "weight"
    t.string   "display_name"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.integer  "report_group_id"
    t.boolean  "violent",         default: false
  end

  create_table "report_groups", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "reports", force: :cascade do |t|
    t.string    "description"
    t.datetime  "report_time"
    t.integer   "report_category_id"
    t.float     "latitude"
    t.float     "longitude"
    t.string    "street_name"
    t.string    "city"
    t.string    "state"
    t.string    "country"
    t.string    "postcode"
    t.datetime  "created_at",                                                                                  null: false
    t.datetime  "updated_at",                                                                                  null: false
    t.geography "location",           limit: {:srid=>4326, :type=>"point", :geographic=>true}
    t.boolean   "invisible",                                                                   default: false
    t.integer   "user_id"
    t.integer   "crime_type_id"
    t.boolean   "crime_day_time"
  end

  add_index "reports", ["location"], name: "index_reports_on_location", using: :gist

  create_table "routes", force: :cascade do |t|
    t.geography "start_point",    limit: {:srid=>4326, :type=>"point", :geographic=>true}
    t.geography "end_point",      limit: {:srid=>4326, :type=>"point", :geographic=>true}
    t.jsonb     "route_response",                                                          default: {}
    t.integer   "crime_day_time"
    t.datetime  "created_at",                                                                           null: false
    t.datetime  "updated_at",                                                                           null: false
  end

  add_index "routes", ["end_point"], name: "index_routes_on_end_point", using: :gist
  add_index "routes", ["route_response"], name: "index_routes_on_route_response", using: :gin
  add_index "routes", ["start_point"], name: "index_routes_on_start_point", using: :gist

  create_table "safer_streets_request", id: :bigserial, force: :cascade do |t|
    t.string   "userid",       limit: 40
    t.string   "email",        limit: 80
    t.string   "name",         limit: 80
    t.string   "city",         limit: 100, null: false
    t.string   "state",        limit: 100, null: false
    t.string   "country",      limit: 100
    t.string   "postcode",     limit: 10
    t.datetime "request_time"
  end

  add_index "safer_streets_request", ["email"], name: "safer_streets_request_email", using: :btree
  add_index "safer_streets_request", ["userid"], name: "safer_streets_request_userid", using: :btree

  create_table "scheduled_jobs", force: :cascade do |t|
    t.string   "cron_schedule"
    t.datetime "last_run_date"
    t.datetime "next_run_date"
    t.string   "description"
    t.string   "job_command"
    t.string   "status"
    t.integer  "city_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "subscription_notification_request", id: :bigserial, force: :cascade do |t|
    t.string   "email",        limit: 80,  null: false
    t.string   "city",         limit: 100, null: false
    t.string   "state",        limit: 100, null: false
    t.string   "country",      limit: 3,   null: false
    t.datetime "request_time"
  end

  add_index "subscription_notification_request", ["country", "state", "city"], name: "subscription_notification_request_country_state_city", using: :btree
  add_index "subscription_notification_request", ["email"], name: "subscription_notification_request_email", using: :btree

  create_table "tips", force: :cascade do |t|
    t.text      "description"
    t.geography "location",          limit: {:srid=>4326, :type=>"point", :geographic=>true}
    t.string    "username"
    t.string    "user_id"
    t.boolean   "archived"
    t.boolean   "is_time_sensitive"
    t.datetime  "expiry_date"
    t.datetime  "created_at",                                                                 null: false
    t.datetime  "updated_at",                                                                 null: false
    t.string    "photo_id"
  end

  add_index "tips", ["location"], name: "index_tips_on_location", using: :gist

  create_table "user_street_safety_rating_logs", id: :bigserial, force: :cascade do |t|
    t.string   "crime_streets_id",          limit: 40,  null: false
    t.float    "latitude"
    t.float    "longitude"
    t.integer  "user_street_safety_rating",             null: false
    t.integer  "accuracy",                              null: false
    t.datetime "user_rating_time"
    t.string   "userid",                    limit: 255
    t.string   "city",                      limit: 100
    t.string   "state",                     limit: 100
    t.string   "country",                   limit: 100
    t.string   "postcode",                  limit: 255
  end

  create_table "users", force: :cascade do |t|
    t.string   "name",                   default: "", null: false
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
    t.string   "display_name"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "zones", force: :cascade do |t|
    t.string   "name"
    t.geometry "area",       limit: {:srid=>0, :type=>"geometry"}
    t.string   "zone_type"
    t.integer  "city_id"
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.boolean  "dark"
    t.boolean  "daytime"
    t.string   "area_types"
    t.integer  "poi_id"
  end

  add_index "zones", ["area"], name: "index_zones_on_area", using: :gist
  add_index "zones", ["city_id"], name: "index_zones_on_city_id", using: :btree
  add_index "zones", ["poi_id"], name: "index_zones_on_poi_id", using: :btree

  add_foreign_key "api_keys", "users"
  add_foreign_key "crime_data", "cities", name: "crime_data_city_id_fkey"
  add_foreign_key "crime_data", "crime_type_descriptions", name: "crime_data_crime_type_description_id_fkey"
  add_foreign_key "crime_data", "crime_types", name: "crime_data_crime_type_id_fkey"
  add_foreign_key "crime_grids", "cities"
  add_foreign_key "crime_type_descriptions", "crime_types", name: "crime_type_desciptions_crime_type_id_fkey"
  add_foreign_key "crime_types", "crime_types", column: "subtype_of", name: "crime_types_subtype_of_fkey"
  add_foreign_key "crime_types", "report_categories"
  add_foreign_key "external_auths", "users"
  add_foreign_key "reports", "users"
  add_foreign_key "zones", "cities"
end
