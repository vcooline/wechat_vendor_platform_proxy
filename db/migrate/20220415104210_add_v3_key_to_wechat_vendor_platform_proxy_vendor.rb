class AddV3KeyToWechatVendorPlatformProxyVendor < ActiveRecord::Migration[7.0]
  def change
    rename_column :wxpay_vendors, :sign_key, :v2_key
    add_column :wxpay_vendors, :v3_key, :string
  end
end
