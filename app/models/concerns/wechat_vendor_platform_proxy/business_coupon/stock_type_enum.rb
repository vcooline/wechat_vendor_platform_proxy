module WechatVendorPlatformProxy
  module BusinessCoupon::StockTypeEnum
    extend ActiveSupport::Concern

    included do
      enum :stock_type, {
        normal: 10,
        discount: 20,
        exchange: 30
      }
    end
  end
end
