module WechatVendorPlatformProxy
  module V3
    class SubApplymentQueryJob < ApplicationJob
      queue_as :default

      def perform(applyment_id)
        applyment = SubApplyment.find(applyment_id)
        vendor = applyment.owner.wechat_sp_vendor
        SubApplymentService.new(vendor).query(applyment)
      end
    end
  end
end
