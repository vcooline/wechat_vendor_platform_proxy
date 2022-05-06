class RenameWechatVendorPlatformProxyStockStateToState < ActiveRecord::Migration[7.0]
  def change
    rename_column :wxpay_busifavor_stocks, :stock_state, :state
  end
end
