module WechatVendorPlatformProxy
  class BusinessCoupon::Stock < ApplicationRecord
    include BusinessCoupon::StockTypeEnum

    belongs_to :origin, polymorphic: true
    belongs_to :vendor, class_name: "WechatVendorPlatformProxy::Vendor", foreign_key: :belong_merchant, primary_key: :mch_id

    has_many :coupons, foreign_key: :stock_id, primary_key: :stock_id

    enum :state, {
      ready: 0,
      unaudit: 10,
      running: 20,
      stoped: 30,
      paused: 40
    }, default: :ready

    enum :coupon_code_mode, {
      wechatpay_mode: 10,
      merchant_api: 20,
      merchant_upload: 30
    }, default: :merchant_api

    validates_presence_of :out_request_no, :origin_type, :origin_id, :belong_merchant, :stock_type, :coupon_code_mode
    validates_uniqueness_of :stock_id, :out_request_no, allow_blank: true
    validates_uniqueness_of :origin_id, scope: :origin_type

    before_validation :set_initial_attrs, on: :create

    def sp_vendor
      vendor.sp_vendor
    end

    private

      def set_initial_attrs
        self.out_request_no ||= "#{self.belong_merchant}#{DateTime.now.strftime('%Y%m%d%H%M%S')}#{SecureRandom.rand(100..999)}"
        self.coupon_use_rule ||= {}
        self.stock_send_rule ||= {}
        self.custom_entrance ||= {}
        self.display_pattern_info ||= {}
        self.notify_config ||= {}
        self.send_count_information ||= {}
      end
  end
end
