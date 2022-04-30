module WechatVendorPlatformProxy
  class BusinessCoupon::CallbackEventJob < ApplicationJob
    queue_as :default

    def perform(vendor_id, event_params)
      Vendor.find_by(id: vendor_id)&.then do |vendor|
        Marketing::BusinessCouponCallbackHandler.new(vendor).perform(event_params)
      end
    end
  end
end
