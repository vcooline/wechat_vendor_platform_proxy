module WechatVendorPlatformProxy
  module V3
    class SubApplymentSubmitJob < ApplicationJob
      queue_as :default

      def perform(applyment_id)
        applyment = SubApplyment.find(applyment_id)
        vendor = applyment.owner.wechat_sp_vendor
        SubApplymentService.new(vendor).submit(applyment)
      end
    end
  end
end
