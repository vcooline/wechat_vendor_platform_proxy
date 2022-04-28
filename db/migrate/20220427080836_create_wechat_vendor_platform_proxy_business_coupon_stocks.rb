class CreateWechatVendorPlatformProxyBusinessCouponStocks < ActiveRecord::Migration[7.0]
  def change
    create_table :wxpay_busifavor_stocks do |t|
      t.belongs_to :origin, polymorphic: true, index: { name: "index_wxpay_busifavor_stocks_on_origin", unique: true }
      t.string :stock_id, index: { unique: true }
      t.string :out_request_no, index: { unique: true }
      t.string :belong_merchant, index: true
      t.string :stock_name
      t.string :comment
      t.string :goods_name
      t.integer :stock_type
      t.integer :stock_state
      t.integer :coupon_code_mode
      t.jsonb :coupon_use_rule
      t.jsonb :stock_send_rule
      t.jsonb :custom_entrance
      t.jsonb :display_pattern_info
      t.jsonb :notify_config
      t.jsonb :send_count_information

      t.timestamps
    end
  end
end
