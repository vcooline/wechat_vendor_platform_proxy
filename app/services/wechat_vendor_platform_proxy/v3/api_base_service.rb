module WechatVendorPlatformProxy
  module V3
    class ApiBaseService < VendorBaseService
      def api_client
        @api_client ||= ApiClient.new(vendor)
      end

      def upload_client
        @upload_client ||= UploadClient.new(vendor)
      end

      def cipher
        @cipher ||= CipherService.new(vendor)
      end

      def media_service
        @media_service ||= MediaService.new(vendor)
      end
    end
  end
end
