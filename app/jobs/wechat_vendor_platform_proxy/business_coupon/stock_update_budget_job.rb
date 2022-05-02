module WechatVendorPlatformProxy
  class BusinessCoupon::StockUpdateBudgetJob < ApplicationJob
    queue_as :low

    def perform(stock_id, target_max_coupons: nil, current_max_coupons: nil)
      BusinessCoupon::Stock.find_by(id: stock_id)&.then do |stock|
        Marketing::BusinessCouponService.new(stock.vendor).update_stock_budget(stock, target_max_coupons:, current_max_coupons:)
      end
    end
  end
end
