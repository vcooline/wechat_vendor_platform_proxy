module WechatVendorPlatformProxy
  module V3
    class SignatureService < VendorBaseService
      AUTH_TYPE = "WECHATPAY2-SHA256-RSA2048".FREEZE

      def build_authorization_header(http_method, fullpath, payload = nil)
        timestamp = Time.now.to_i
        nonce_str = SecureRandom.base58
        signature = sign("SHA256", [http_method, fullpath, timestamp, nonce_str, payload].join("\n"))

        { mchid: vendor.mch_id, serial_no: vendor.api_client_serial_no, nonce_str:, timestamp:, signature: }
          .map { |k, v| "#{k}=\"#{v}\"" }
          .join(",")
          .then { |auth_value| "#{AUTH_TYPE} #{auth_value}" }
      end

      def sign(text)
        OpenSSL::PKey::RSA.new(vendor.api_client_key).sign("SHA256", text)
      end
    end
  end
end
