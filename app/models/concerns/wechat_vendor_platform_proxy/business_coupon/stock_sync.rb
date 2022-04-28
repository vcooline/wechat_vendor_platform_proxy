module WechatVendorPlatformProxy
  module BusinessCoupon::StockSync
    extend ActiveSupport::Concern

    included do
      has_one :wxpay_business_coupon_stock, as: :origin, class_name: "WechatVendorPlatformProxy::BusinessCoupon::Stock"
    end
  end
end
