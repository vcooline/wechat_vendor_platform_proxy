class CreateWechatVendorPlatformProxyBusinessCouponCoupons < ActiveRecord::Migration[7.0]
  def change
    create_table :wxpay_busifavor_coupons do |t|
      t.belongs_to :origin, polymorphic: true, index: { name: "index_wxpay_busifavor_coupons_on_origin", unique: true }
      t.string :stock_id, index: true
      t.string :send_request_no, index: { unique: true }
      t.string :use_request_no, index: { unique: true }
      t.string :code, index: { unique: true }
      t.string :stock_name
      t.string :comment
      t.string :goods_name
      t.integer :stock_type
      t.integer :state
      t.jsonb :coupon_use_rule
      t.datetime :available_start_time
      t.datetime :expire_time
      t.datetime :receive_time
      t.datetime :use_time
      t.string :app_id
      t.string :open_id

      t.timestamps
    end
  end
end
