module WechatVendorPlatformProxy
  module V3
    class GoldPlanConfigureJob < ApplicationJob
      queue_as :low

      def perform(sp_mch_id:, sub_mch_id:)
        WechatVendorPlatformProxy::Vendor.find_by(mch_id: sp_mch_id)&.then do |vendor|
          GoldPlanService.new(vendor)
            .tap { |service| service.set_gold_plan(sub_mch_id) }
            .tap { |service| service.set_custom_page(sub_mch_id) }
            .tap { |service| service.close_advertising_show(sub_mch_id) }
        end
      end
    end
  end
end
