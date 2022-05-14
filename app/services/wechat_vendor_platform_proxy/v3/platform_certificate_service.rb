module WechatVendorPlatformProxy
  module V3
    class PlatformCertificateService < ApiBaseService
      SignError = Class.new StandardError

      def get(decrypt: true)
        resp = api_client.get "/v3/certificates"
        resp_info = JSON.parse(resp.body)
        raise SignError, resp_info["message"] if resp_info["code"].eql?("SIGN_ERROR")

        resp_info["data"].map do |cert_info|
          cert_info["cert"] = cipher.decrypt_params(**cert_info["encrypt_certificate"].slice("ciphertext", "nonce", "associated_data").symbolize_keys) if decrypt
          cert_info
        end
      end

      def sync
        cert_infos = get(decrypt: true)
        clean(cert_infos)
        save_all(cert_infos)
      end

      private

        def clean(cert_infos)
          serial_numbers = cert_infos.map { |info| info["serial_no"] }
          vendor.platform_certificates.where.not(serial_no: serial_numbers).destroy_all
        end

        def save_all(cert_infos)
          cert_infos.map do |cert_info|
            vendor.platform_certificates.find_or_initialize_by(serial_no: cert_info["serial_no"]).tap do |c|
              c.update \
                cert: cert_info["cert"],
                effective_at: cert_info["effective_time"],
                expire_at: cert_info["expire_time"]
            end
          end
        end
    end
  end
end
