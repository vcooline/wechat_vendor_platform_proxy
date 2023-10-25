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

ActiveRecord::Schema[7.1].define(version: 2099_11_17_054718) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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

  create_table "wxpay_api_client_certificates", force: :cascade do |t|
    t.bigint "vendor_id"
    t.datetime "effective_at"
    t.datetime "expire_at"
    t.string "serial_no"
    t.text "key"
    t.text "cert"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["vendor_id"], name: "index_wxpay_api_client_certificates_on_vendor_id"
  end

  create_table "wxpay_busifavor_coupons", force: :cascade do |t|
    t.string "origin_type"
    t.bigint "origin_id"
    t.string "stock_id"
    t.string "send_request_no"
    t.string "use_request_no"
    t.string "return_request_no"
    t.string "deactivate_request_no"
    t.string "deactivate_reason"
    t.string "code"
    t.string "stock_name"
    t.string "comment"
    t.string "goods_name"
    t.integer "stock_type"
    t.integer "state"
    t.jsonb "coupon_use_rule"
    t.datetime "available_start_time"
    t.datetime "expire_time"
    t.datetime "receive_time"
    t.datetime "use_time"
    t.datetime "return_time"
    t.datetime "deactivate_time"
    t.string "app_id"
    t.string "open_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_wxpay_busifavor_coupons_on_code", unique: true
    t.index ["origin_type", "origin_id"], name: "index_wxpay_busifavor_coupons_on_origin", unique: true
    t.index ["send_request_no"], name: "index_wxpay_busifavor_coupons_on_send_request_no", unique: true
    t.index ["stock_id"], name: "index_wxpay_busifavor_coupons_on_stock_id"
    t.index ["use_request_no"], name: "index_wxpay_busifavor_coupons_on_use_request_no", unique: true
  end

  create_table "wxpay_busifavor_stocks", force: :cascade do |t|
    t.string "origin_type"
    t.bigint "origin_id"
    t.string "stock_id"
    t.string "out_request_no"
    t.string "belong_merchant"
    t.string "stock_name"
    t.string "comment"
    t.string "goods_name"
    t.integer "stock_type"
    t.integer "state"
    t.integer "coupon_code_mode"
    t.jsonb "coupon_use_rule"
    t.jsonb "stock_send_rule"
    t.jsonb "custom_entrance"
    t.jsonb "display_pattern_info"
    t.jsonb "notify_config"
    t.jsonb "send_count_information"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["belong_merchant"], name: "index_wxpay_busifavor_stocks_on_belong_merchant"
    t.index ["origin_type", "origin_id"], name: "index_wxpay_busifavor_stocks_on_origin", unique: true
    t.index ["out_request_no"], name: "index_wxpay_busifavor_stocks_on_out_request_no", unique: true
    t.index ["stock_id"], name: "index_wxpay_busifavor_stocks_on_stock_id", unique: true
  end

  create_table "wxpay_capital_bank_branches", force: :cascade do |t|
    t.string "bank_alias_code"
    t.string "bank_branch_name"
    t.string "bank_branch_id"
    t.string "province_name"
    t.string "province_code"
    t.string "city_name"
    t.string "city_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bank_alias_code"], name: "index_wxpay_capital_bank_branches_on_bank_alias_code"
  end

  create_table "wxpay_capital_corporate_banks", force: :cascade do |t|
    t.string "account_bank"
    t.integer "account_bank_code"
    t.string "bank_alias"
    t.string "bank_alias_code"
    t.boolean "need_bank_branch"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "wxpay_capital_personal_banks", force: :cascade do |t|
    t.string "account_bank"
    t.integer "account_bank_code"
    t.string "bank_alias"
    t.string "bank_alias_code"
    t.boolean "need_bank_branch"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "wxpay_ecommerce_applyments", force: :cascade do |t|
    t.string "owner_type"
    t.bigint "owner_id"
    t.integer "state"
    t.string "out_request_no"
    t.string "merchant_shortname"
    t.integer "organization_type"
    t.jsonb "business_license_info"
    t.jsonb "id_card_info"
    t.boolean "need_account_info"
    t.jsonb "account_info"
    t.jsonb "contact_info"
    t.jsonb "sales_scene_info"
    t.jsonb "qualifications"
    t.jsonb "business_addition_pics"
    t.text "business_addition_desc"
    t.string "applyment_id"
    t.text "state_desc"
    t.string "sign_state"
    t.string "sign_url"
    t.jsonb "account_validation"
    t.jsonb "audit_detail"
    t.string "legal_validation_url"
    t.string "sub_mch_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["out_request_no"], name: "index_wxpay_ecommerce_applyments_on_out_request_no", unique: true
    t.index ["owner_type", "owner_id"], name: "index_wxpay_ecommerce_applyments_on_owner"
  end

  create_table "wxpay_platform_certificates", force: :cascade do |t|
    t.bigint "vendor_id"
    t.datetime "effective_at"
    t.datetime "expire_at"
    t.string "serial_no"
    t.text "cert"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["vendor_id"], name: "index_wxpay_platform_certificates_on_vendor_id"
  end

  create_table "wxpay_profit_sharing_receivers", force: :cascade do |t|
    t.bigint "vendor_id"
    t.string "app_id"
    t.integer "account_type"
    t.string "account"
    t.string "name"
    t.integer "relation_type"
    t.string "custom_relation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account", "vendor_id", "app_id"], name: "index_wxpay_profit_sharing_receivers_on_vendor_app_account", unique: true
    t.index ["vendor_id"], name: "index_wxpay_profit_sharing_receivers_on_vendor_id"
  end

  create_table "wxpay_settlement_accounts", force: :cascade do |t|
    t.string "sub_mch_id"
    t.string "account_type"
    t.string "account_bank"
    t.string "bank_address_code"
    t.string "bank_name"
    t.string "bank_branch_id"
    t.string "account_number"
    t.string "verify_result"
    t.text "verify_fail_reason"
    t.integer "state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sub_mch_id"], name: "index_wxpay_settlement_accounts_on_sub_mch_id"
  end

  create_table "wxpay_sub_applyments", force: :cascade do |t|
    t.string "owner_type"
    t.bigint "owner_id"
    t.string "business_code"
    t.jsonb "contact_info"
    t.jsonb "subject_info"
    t.jsonb "business_info"
    t.jsonb "settlement_info"
    t.jsonb "bank_account_info"
    t.jsonb "addition_info"
    t.string "applyment_id"
    t.string "sign_url"
    t.string "sub_mchid"
    t.integer "state"
    t.text "state_message"
    t.jsonb "audit_detail"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["business_code"], name: "index_wxpay_sub_applyments_on_business_code", unique: true
    t.index ["owner_type", "owner_id"], name: "index_wxpay_sub_applyments_on_owner"
  end

  create_table "wxpay_vendors", force: :cascade do |t|
    t.string "mch_id"
    t.integer "type"
    t.string "v2_key"
    t.text "comment"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "v3_key"
    t.string "sp_mch_id"
    t.decimal "fee_rate", precision: 4, scale: 4
    t.index ["mch_id"], name: "index_wxpay_vendors_on_mch_id", unique: true
    t.index ["sp_mch_id"], name: "index_wxpay_vendors_on_sp_mch_id"
  end

  create_table "wxpay_verify_files", force: :cascade do |t|
    t.string "name"
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_wxpay_verify_files_on_name", unique: true
  end

end
