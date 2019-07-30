module WechatVendorPlatformProxy
  class SignatureService
    attr_reader :vendor

    class << self
      def sign(sign_params={})
        new(get_vendor(sign_params[:mch_id])).sign(sign_params)
      end

      def verify_notification_sign(notification_params={})
        notification_sign = notification_params.delete("sign")
        re_sign = Digest::MD5.hexdigest(notification_params.sort.map{ |param| param.join("=") }.join("&") + "&key=" + get_vendor(notification_params["sub_mch_id"] || notification_params["mch_id"]).sign_key).upcase
        ActiveSupport::SecurityUtils.secure_compare(notification_sign, re_sign)
      end

      private
        def get_vendor(mch_id)
          ::WechatVendorPlatformProxy::Vendor.find_by!(mch_id: mch_id)
        end
    end

    def initialize(vendor)
      @vendor = vendor
    end

    def sign(p)
      Digest::MD5.hexdigest(p.sort.map{|k, v| "#{k}=#{v}" }.join("&").to_s + "&key=#{vendor.sign_key}").upcase
      # Digest::MD5.hexdigest("#{URI.unescape(p.to_query)}&key=#{vendor.sign_key}").upcase
    end
  end
end
