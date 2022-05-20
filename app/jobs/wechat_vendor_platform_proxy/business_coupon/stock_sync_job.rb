module WechatVendorPlatformProxy
  class BusinessCoupon::StockSyncJob < ApplicationJob
    queue_as :low

    def perform(stock_id)
      BusinessCoupon::Stock.find_by(id: stock_id)&.then do |stock|
        Marketing::BusinessCouponService.new(stock.sp_vendor).sync_stock(stock)
      end
    end
  end
end
