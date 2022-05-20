class AddSpMchIdToWechatVendorPlatformProxyVendor < ActiveRecord::Migration[7.0]
  def change
    add_column :wxpay_vendors, :sp_mch_id, :string
    add_index :wxpay_vendors, :sp_mch_id
  end
end
