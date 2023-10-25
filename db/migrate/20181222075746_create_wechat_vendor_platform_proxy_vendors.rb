class CreateWechatVendorPlatformProxyVendors < ActiveRecord::Migration[5.2]
  def change
    create_table :wxpay_vendors do |t|
      t.string :mch_id, index: { unique: true }
      t.integer :type
      t.string :sign_key
      t.text :api_client_key
      t.text :api_client_cert
      t.text :comment

      t.timestamps null: false
    end
  end
end
