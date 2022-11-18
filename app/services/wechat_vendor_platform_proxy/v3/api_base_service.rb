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

      def signer
        @signer ||= SignatureService.new(vendor)
      end

      def media_service
        @media_service ||= MediaService.new(vendor)
      end

      private

        def parse_resp_with_error_handling(resp)
          JSON.parse(resp.body).tap do |resp_info|
            raise ("#{self.class.name}::#{resp_info['code'].underscore.camelize}".safe_constantize || StandardError), resp_info["message"] unless resp.success?
          end
        end

        def handle_api_error(resp_info)
          raise ("#{self.class.name}::#{resp_info['code'].underscore.camelize}".safe_constantize || StandardError), resp_info["message"]
        end
    end
  end
end
