module WechatVendorPlatformProxy
  module V3
    class ApiClient < VendorBaseService
      API_GATEWAY = "https://api.mch.weixin.qq.com".freeze

      def get(...)
        api_call("GET", ...)
      end

      def post(...)
        api_call("POST", ...)
      end

      private

        def connection(http_method, fullpath, payload, extra_headers: {})
          Faraday.new(
            url: API_GATEWAY,
            headers: {
              Accept: "application/json",
              Authorization: SignatureService.new(vendor).build_authorization_header(http_method, fullpath, payload)
            }.merge(extra_headers).compact
          )
        end

        def api_call(http_method, fullpath, payload = nil, extra_headers: {})
          Rails.logger.info "#{self.class.name} #{http_method} #{fullpath} reqt: #{payload&.squish}"
          resp = connection(http_method, fullpath, payload, extra_headers:)
            .public_send(http_method.downcase, fullpath, payload)
          Rails.logger.info "#{self.class.name} #{http_method} #{fullpath} resp(#{resp.status}): #{resp.body.squish}"

          resp
        end
    end
  end
end
