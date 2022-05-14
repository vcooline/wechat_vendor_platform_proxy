module WechatVendorPlatformProxy
  class ECommerce::ApplymentSubmitJob < ApplicationJob
    queue_as :default

    def perform(applyment_id)
      applyment = ECommerce::Applyment.find(applyment_id)
      vendor = applyment.owner.wechat_sp_vendor
      ECommerce::ApplymentService.new(vendor).submit(applyment)
    end
  end
end
