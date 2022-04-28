module WechatVendorPlatformProxy
  class BusinessCoupon::Coupon < ApplicationRecord
    include BusinessCoupon::StockTypeEnum

    belongs_to :origin, polymorphic: true

    belongs_to :stock, foreign_key: :stock_id, primary_key: :stock_id

    enum :state, {
      ready: 0,
      sended: 2,
      deactivated: 7,
      used: 8,
      expired: 9
    }, default: :ready

    validates_presence_of :stock_id, :send_request_no, :code
    validates_uniqueness_of :code

    before_validation :set_initial_attrs, on: :create

    private

      def set_initial_attrs
        self.code ||= origin.code if origin.has_attribute?(:code)
        self.stock_name ||= stock.stock_name
        self.comment ||= stock.comment
        self.goods_name ||= stock.goods_name
        self.stock_type ||= stock.stock_type
        self.coupon_use_rule ||= self.coupon_use_rule
      end
  end
end
