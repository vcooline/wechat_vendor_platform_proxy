module WechatVendorPlatformProxy
  module V3
    class CipherService < VendorBaseService
      def self.decrypt_params(serial_no, ...)
        PlatformCertificate.find_by!(serial_no:).vendor.then do |vendor|
          new(vendor).decrypt_params(...)
        end
      end

      def platform_encrypt(original_text)
        OpenSSL::X509::Certificate.new(vendor.latest_platform_certficate.cert)
          .public_key
          .public_encrypt(original_text, OpenSSL::PKey::RSA::PKCS1_OAEP_PADDING)
          .then { |c| Base64.strict_encode64(c) }
      end
      alias_method :encrypt, :platform_encrypt

      def api_client_encrypt(original_text)
        OpenSSL::X509::Certificate.new(vendor.latest_api_client_certificate.cert)
          .public_key
          .public_encrypt(original_text, OpenSSL::PKey::RSA::PKCS1_OAEP_PADDING)
          .then { |c| Base64.strict_encode64(c) }
      end

      def api_client_decrypt(original_text, cert_serial_no: vendor.latest_api_client_certificate&.serial_no)
        vendor.api_client_certificates.find_by(serial_no: cert_serial_no)
          .then { |certificate| OpenSSL::PKey::RSA.new(certificate&.key) }
          .then { |rsa_private| rsa_private.private_decrypt(Base64.strict_decode64(original_text), OpenSSL::PKey::RSA::PKCS1_OAEP_PADDING) }
          .then { |text| text.force_encoding("utf-8") }
      end
      alias_method :decrypt, :api_client_decrypt

      def decrypt_params(ciphertext:, nonce:, associated_data:)
        tag_length = 16
        auth_tag, content = Base64.strict_decode64(ciphertext)
          .then { |text| [text.slice(-tag_length..-1), text.slice(0...-tag_length)] }
        OpenSSL::Cipher.new("aes-256-gcm")
          .decrypt
          .tap { |c| c.key = vendor.v3_key }
          .tap { |c| c.iv = nonce }
          .tap { |c| c.auth_tag = auth_tag }
          .tap { |c| c.auth_data = associated_data }
          .then { |c| c.update(content) }
      end
    end
  end
end
