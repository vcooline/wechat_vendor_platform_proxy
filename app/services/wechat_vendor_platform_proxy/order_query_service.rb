module WechatVendorPlatformProxy
  class OrderQueryService
    attr_reader :vendor

    class << self
      def perform(order_params={})
        new(get_vendor(order_params[:sub_mch_id] || order_params[:mch_id])).perform(order_params)
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
    #     sub_appid: "", (optional)
    #     mch_id: "",
    #     sub_mch_id: "",, (optional)
    #     out_trade_no: "", (transaction_id: "")
    #   }
    def perform(order_params={})
      request_params = generate_order_params(order_params)
      call_order_api(request_params)
    end

    private
      def sign_params(p)
        Digest::MD5.hexdigest(p.sort.map{|k, v| "#{k}=#{v}" }.join("&").to_s + "&key=#{vendor.sign_key}").upcase
      end

      def generate_order_params(base_params)
        base_params.reverse_merge(
          nonce_str: SecureRandom.hex
        ).tap { |p| p[:sign] = sign_params(p) }
      end

      def call_order_api(request_params)
        Rails.logger.info "WechatVendorPlatformProxy OrderQueryService call order api reqt: #{request_params.to_json}"
        resp = Faraday.post "https://api.mch.weixin.qq.com/pay/orderquery", request_params.to_xml(dasherize: false)
        Rails.logger.info "WechatVendorPlatformProxy OrderQueryService call order api resp(#{resp.status}):\n#{resp.body}"
        Hash.from_xml(resp.body)["xml"]
      end
  end
end
