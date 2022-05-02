module WechatVendorPlatformProxy
  class BusinessCoupon::CouponDeactivateJob < ApplicationJob
    queue_as :low

    def perform(coupon_id)
      BusinessCoupon::Coupon.find_by(id: coupon_id)&.then do |coupon|
        Marketing::BusinessCouponService.new(coupon.vendor).deactivate_coupon(coupon)
      end
    end
  end
end
