module WechatVendorPlatformProxy
  class BusinessCoupon::StockUpdateInfoJob < ApplicationJob
    queue_as :low

    def perform(stock_id)
      BusinessCoupon::Stock.find_by(id: stock_id)&.then do |stock|
        Marketing::BusinessCouponService.new(stock).update_stock_info(stock)
      end
    end
  end
end
