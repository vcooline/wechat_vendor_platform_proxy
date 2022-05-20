class CreateWechatVendorPlatformProxyECommerceVendors < ActiveRecord::Migration[7.0]
  def change
    create_table :wxpay_ecommerce_vendors do |t|
      t.string :sp_mch_id, index: true
      t.string :sub_mch_id, index: { unique: true }

      t.timestamps
    end
  end
end
