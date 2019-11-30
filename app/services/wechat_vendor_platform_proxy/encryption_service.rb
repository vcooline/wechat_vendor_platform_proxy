module WechatVendorPlatformProxy
  class EncryptionService
    attr_reader :vendor

    class << self
      def decrypt_refund_info(raw_content)
        return_info = Hash.from_xml(raw_content)["xml"]
        req_info = Hash.from_xml(new(get_vendor(return_info["sub_mch_id"] || return_info["mch_id"])).decrypt(return_info["req_info"]))["root"]
        return_info.except("req_info").merge(req_info)
      end

      private
        def get_vendor(mch_id)
          ::WechatVendorPlatformProxy::Vendor.find_by!(mch_id: mch_id)
        end
    end

    def initialize(vendor)
      @vendor = vendor
    end

    def encrypt(original_content="")
    end

    def decrypt(encrypted_content="")
      OpenSSL::Cipher.new('AES-256-ECB')
        .decrypt
        .tap{ |c| c.padding = 0 }
        .tap{ |c| c.key = Digest::MD5.hexdigest(vendor.sign_key) }
        .then{ |c| c.update(Base64.decode64(encrypted_content)) << c.final }
        .strip
    end
  end
end
