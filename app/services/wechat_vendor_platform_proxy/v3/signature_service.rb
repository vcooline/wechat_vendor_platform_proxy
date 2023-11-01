module WechatVendorPlatformProxy
  module V3
    class SignatureService < VendorBaseService
      AUTH_TYPE = "WECHATPAY2-SHA256-RSA2048".freeze

      InvalidPlatformSerialNoError = Class.new StandardError
      InvalidHeaderSignatureError = Class.new StandardError

      class << self
        def verify_authorization_header(headers, payload = nil)
          vendor = detect_vendor_by_platform_serial_no(headers["Wechatpay-Serial"])
          return if OpenSSL::X509::Certificate.new(vendor.latest_platform_certificate.cert).public_key.verify \
            "SHA256",
            Base64.strict_decode64(headers["Wechatpay-Signature"]),
            "#{headers['Wechatpay-Timestamp']}\n#{headers['Wechatpay-Nonce']}\n#{payload}\n"

          raise InvalidHeaderSignatureError, "Invalid header signature"
        end

        def detect_vendor_by_platform_serial_no(serial_no)
          certificate = PlatformCertificate.find_by(serial_no:)
          raise InvalidPlatformSerialNoError, "Invalid wechat pay certificate serial_no" if certificate.blank?

          certificate.vendor
        end
      end

      def build_authorization_header(http_method, fullpath, payload = nil)
        timestamp = Time.now.to_i
        nonce_str = SecureRandom.base58
        signature = sign(http_method, fullpath, timestamp, nonce_str, payload)

        { mchid: vendor.mch_id, serial_no: vendor.latest_api_client_certificate.serial_no, nonce_str:, timestamp:, signature: }
          .map { |k, v| "#{k}=\"#{v}\"" }
          .join(",")
          .then { |auth_value| "#{AUTH_TYPE} #{auth_value}" }
      end

      def sign(*args)
        args
          .map { |arg| "#{arg}\n" }
          .join
          .then { |txt| OpenSSL::PKey::RSA.new(vendor.latest_api_client_certificate.key).sign("SHA256", txt) }
          .then { |txt| Base64.strict_encode64(txt) }
      end
    end
  end
end
