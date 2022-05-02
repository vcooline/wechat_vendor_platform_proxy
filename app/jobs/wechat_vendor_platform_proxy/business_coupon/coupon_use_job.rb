module WechatVendorPlatformProxy
  class BusinessCoupon::CouponUseJob < ApplicationJob
    queue_as :low

    def perform(coupon_id)
      BusinessCoupon::Coupon.find_by(id: coupon_id)&.then do |coupon|
        Marketing::BusinessCouponService.new(coupon.vendor).use_coupon(coupon)
      end
    end
  end
end
