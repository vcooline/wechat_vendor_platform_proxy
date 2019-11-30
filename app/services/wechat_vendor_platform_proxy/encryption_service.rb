module WechatVendorPlatformProxy
  class EncryptionService
    attr_reader :vendor

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
        .then{ |c| c.update(Base64.decode64(result["req_info"])) << c.final }
        .strip
    end
  end
end
