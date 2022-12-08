class AddFeeRateToWechatVendorPlatformProxyVendors < ActiveRecord::Migration[7.0]
  def change
    add_column :wxpay_vendors, :fee_rate, :decimal, precision: 4, scale: 4
  end
end
