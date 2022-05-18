class CreateWechatVendorPlatformProxyVerifyFiles < ActiveRecord::Migration[7.0]
  def change
    create_table :wxpay_verify_files do |t|
      t.string :name, index: { unique: true }
      t.text :content

      t.timestamps
    end
  end
end
