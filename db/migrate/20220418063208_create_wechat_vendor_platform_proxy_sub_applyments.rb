class CreateWechatVendorPlatformProxySubApplyments < ActiveRecord::Migration[7.0]
  def change
    create_table :wxpay_sub_applyments do |t|
      t.belongs_to :owner, polymorphic: true, index: { name: "index_wxpay_sub_applyments_on_owner" }
      t.string :business_code, index: { unique: true }
      t.jsonb :contact_info
      t.jsonb :subject_info
      t.jsonb :business_info
      t.jsonb :settlement_info
      t.jsonb :bank_account_info
      t.jsonb :addition_info

      t.string :applyment_id
      t.string :sign_url
      t.string :sub_mchid

      t.integer :state
      t.text :state_message
      t.jsonb :audit_detail

      t.timestamps
    end
  end
end
