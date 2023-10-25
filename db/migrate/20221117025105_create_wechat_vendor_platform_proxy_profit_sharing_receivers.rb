class CreateWechatVendorPlatformProxyProfitSharingReceivers < ActiveRecord::Migration[7.0]
  def change
    create_table :wxpay_profit_sharing_receivers do |t|
      t.belongs_to :vendor
      t.string :app_id
      t.integer :account_type
      t.string :account
      t.string :name
      t.integer :relation_type
      t.string :custom_relation

      t.timestamps

      t.index %i[account vendor_id app_id], name: "index_wxpay_profit_sharing_receivers_on_vendor_app_account", unique: true
    end
  end
end
