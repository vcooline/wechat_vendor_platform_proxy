module WechatVendorPlatformProxy
  module V3
    class CipherService < VendorBaseService
      def encrypt(original_text)
        OpenSSL::X509::Certificate.new(vendor.latest_platform_certficate.cert)
          .public_key
          .public_encrypt(original_text, OpenSSL::PKey::RSA::PKCS1_OAEP_PADDING)
          .then { |c| Base64.strict_encode64(c) }
      end

      def decrypt(ciphertext:, nonce:, associated_data:)
        tag_length = 16
        auth_tag, content = Base64.strict_decode64(ciphertext)
          .then { |text| [text.slice(-tag_length..-1), text.slice(0...-tag_length)] }
        OpenSSL::Cipher.new("AES-256-GCM")
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
