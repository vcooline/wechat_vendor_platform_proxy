class CreateWechatVendorPlatformProxyPlatformCertificates < ActiveRecord::Migration[7.0]
  def change
    create_table :wxpay_platform_certificates do |t|
      t.belongs_to :vendor, foreign_key: { to_table: :wxpay_vendors }
      t.datetime :effective_at
      t.datetime :expire_at
      t.string :serial_no
      t.text :cert

      t.timestamps
    end
  end
end
