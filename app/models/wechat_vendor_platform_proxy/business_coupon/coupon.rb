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

    before_validation :set_initial_attrs, :sync_stock_attrs, on: :create

    delegate :belong_merchant, :vendor, :sp_vendor, to: :stock

    def to_receive_url
      Marketing::BusinessCouponService.new(sp_vendor).receive_coupon_url(self)
    end

    private

      def set_initial_attrs
        self.code ||= origin.code if origin&.has_attribute?(:code)
        self.send_request_no ||= "#{self.belong_merchant}#{DateTime.now.strftime('%Y%m%d%H%M%S')}#{SecureRandom.rand(100..999)}"
        self.use_request_no ||= "#{self.belong_merchant}#{DateTime.now.strftime('%Y%m%d%H%M%S')}#{SecureRandom.rand(100..999)}"
        self.return_request_no ||= "#{self.belong_merchant}#{DateTime.now.strftime('%Y%m%d%H%M%S')}#{SecureRandom.rand(100..999)}"
        self.deactivate_request_no ||= "#{self.belong_merchant}#{DateTime.now.strftime('%Y%m%d%H%M%S')}#{SecureRandom.rand(100..999)}"
      end

      def sync_stock_attrs
        self.assign_attributes stock.attributes.slice(*%w[stock_name comment goods_name stock_type coupon_use_rule])
      end
  end
end
