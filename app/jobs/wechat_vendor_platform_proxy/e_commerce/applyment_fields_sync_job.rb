module WechatVendorPlatformProxy
  class ECommerce::ApplymentFieldsSyncJob < ApplicationJob
    queue_as :default

    def perform(applyment_id, changes = {}, trigger_api: true)
      applyment = ECommerce::Applyment.find(applyment_id)
      vendor = applyment.owner.wechat_sp_vendor
      ECommerce::ApplymentService.new(vendor).sync_encrypt_fields(applyment, changes)
      ECommerce::ApplymentService.new(vendor).sync_media_fields(applyment, changes)
      ECommerce::ApplymentSubmitJob.perform_later(applyment_id) if trigger_api
    end
  end
end
