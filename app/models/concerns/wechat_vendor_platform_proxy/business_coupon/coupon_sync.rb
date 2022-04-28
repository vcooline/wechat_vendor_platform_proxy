module WechatVendorPlatformProxy
  module BusinessCoupon::CouponSync
    extend ActiveSupport::Concern

    included do
      has_one :wxpay_business_coupon_coupon, as: :origin, class_name: "WechatVendorPlatformProxy::BusinessCoupon::Coupon"
    end
  end
end
