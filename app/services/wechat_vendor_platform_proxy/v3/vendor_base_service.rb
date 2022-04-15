module WechatVendorPlatformProxy
  module V3
    class VendorBaseService
      attr_reader :vendor

      class << self
        def find_vendor(mch_id)
          ::WechatVendorPlatformProxy::Vendor.find_by!(mch_id:)
        end
      end

      def initialize(vendor)
        @vendor = vendor
      end
    end
  end
end
