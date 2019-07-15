module WechatVendorPlatformProxy
  class UnifiedOrderService
    attr_reader :vendor

    class << self
      def perform(order_params={})
        new(get_vendor(order_params[:mch_id])).perform(order_params)
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

    # order_params example:
    #   {
    #     appid: "",
    #     mch_id: "",
    #     out_trade_no: "",
    #     body: "",
    #     notify_url: "",
    #     trade_type: "",
    #     total_fee: 100,
    #     product_id: ""
    #   }
    def perform(order_params={})
      request_params = generate_order_params(order_params)
      call_order_api(request_params)
    end

    private
      def sign_params(p)
        Digest::MD5.hexdigest(p.sort.map{|k, v| "#{k}=#{v}" }.join("&").to_s + "&key=#{vendor.sign_key}").upcase
        # Digest::MD5.hexdigest("#{URI.unescape(p.to_query)}&key=#{vendor.sign_key}").upcase
      end

      def generate_order_params(base_params)
        base_params.reverse_merge(
          nonce_str: SecureRandom.hex,
          spbill_create_ip: Socket.ip_address_list.detect{|intf| intf.ipv4_private?}.ip_address
        ).tap { |p| p[:sign] = sign_params(p) }
      end

      def call_order_api(request_params)
        Rails.logger.info "WechatVendorPlatformProxy UnifiedOrderService call order api reqt: #{request_params.to_json}"
        resp = Faraday.post "https://api.mch.weixin.qq.com/pay/unifiedorder", request_params.to_xml(dasherize: false)
        Rails.logger.info "WechatVendorPlatformProxy UnifiedOrderService call order api resp(#{resp.status}): #{resp.body.squish}"
        Hash.from_xml(resp.body)["xml"]
      end
  end
end
