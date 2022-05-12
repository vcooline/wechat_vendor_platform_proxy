class CreateWechatVendorPlatformProxyECommerceApplyments < ActiveRecord::Migration[7.0]
  def change
    create_table :wechat_vendor_platform_proxy_e_commerce_applyments do |t|
      t.belongs_to :owner, polymorphic: true, index: { name: "index_wxpay_ecommerce_applyments_on_owner" }
      t.integer :state
      t.string :out_request_no, index: { unique: true, name: "index_wxpay_ecommerce_applyments_on_out_request_no" }
      t.string :merchant_shortname
      t.integer :organization_type
      t.jsonb :business_license_info
      t.jsonb :id_card_info
      t.boolean :need_account_info
      t.jsonb :account_info
      t.jsonb :contact_info
      t.jsonb :sales_scene_info

      t.jsonb :qualifications
      t.jsonb :business_addition_pics
      t.text :business_addition_desc

      t.timestamps
    end
  end
end
