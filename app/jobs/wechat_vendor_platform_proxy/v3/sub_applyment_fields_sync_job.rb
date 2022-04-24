module WechatVendorPlatformProxy
  module V3
    class SubApplymentFieldsSyncJob < ApplicationJob
      queue_as :default

      def perform(applyment_id, changes = {}, trigger_api: true)
        applyment = SubApplyment.find(applyment_id)
        vendor = applyment.owner.wechat_sp_vendor
        SubApplymentService.new(vendor).sync_media_fields(applyment, changes)
        SubApplymentService.new(vendor).sync_encrypt_fields(applyment, changes)
        SubApplymentService.new(vendor).submit(applyment) if trigger_api
      end
    end
  end
end
