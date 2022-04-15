module WechatVendorPlatformProxy
  module V3
    class ApiBaseService < VendorBaseService
      def api_client
        @api_client ||= ApiClient.new(vendor)
      end

      def cipher
        @cipher ||= CipherService.new(vendor)
      end
    end
  end
end
