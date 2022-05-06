module WechatVendorPlatformProxy
  class BusinessCoupon::StockEmptyBudgetJob < ApplicationJob
    queue_as :low

    def perform(stock_id)
      BusinessCoupon::Stock.find_by(id: stock_id)&.then do |stock|
        Marketing::BusinessCouponService.new(stock.vendor).sync_stock(stock)

        target_max_coupons = [1, Hash(stock.send_count_information)["total_send_num"].to_i].max
        Marketing::BusinessCouponService.new(stock.vendor).update_stock_budget(stock, target_max_coupons:)
      end
    end
  end
end