module WechatVendorPlatformProxy
  class EncryptionService
    attr_reader :vendor

    def initialize(vendor)
      @vendor = vendor
    end

    def encrypt(original_content="")
    end

    def decrypt(content="")
    end
  end
end
