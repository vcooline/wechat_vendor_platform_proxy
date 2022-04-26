module WechatVendorPlatformProxy
  module V3
    class PlatformCertificateSyncJob < ApplicationJob
      queue_as :default

      def perform(vendor_id)
        Vendor.find_by(id: vendor_id)&.then do |vendor|
          PlatformCertificateService.new(vendor).sync
        end
      end
    end
  end
end
