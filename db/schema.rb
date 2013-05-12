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

ActiveRecord::Schema.define(:version => 20130510222748) do

  create_table "cells", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "cells", ["id"], :name => "index_cells_on_id", :unique => true

  create_table "module_instances", :force => true do |t|
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.integer  "module_template_id"
    t.integer  "cell_id"
    t.float    "amount"
    t.string   "name"
  end

  add_index "module_instances", ["id"], :name => "index_module_instances_on_id", :unique => true

  create_table "module_parameters", :force => true do |t|
    t.string   "key"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.integer  "module_template_id"
  end

  add_index "module_parameters", ["id"], :name => "index_module_parameters_on_id", :unique => true

  create_table "module_templates", :force => true do |t|
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.string   "name"
    t.text     "step"
    t.string   "file"
    t.string   "javascript_model"
  end

  add_index "module_templates", ["id"], :name => "index_module_templates_on_id", :unique => true

  create_table "module_values", :force => true do |t|
    t.text     "value",               :limit => 255
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.integer  "module_parameter_id"
    t.integer  "module_instance_id"
  end

  create_table "reports", :force => true do |t|
    t.integer  "cell_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "reports", ["id"], :name => "index_reports_on_id", :unique => true

end
