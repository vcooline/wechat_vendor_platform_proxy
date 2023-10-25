module WechatVendorPlatformProxy
  class JsapiOrderService
    attr_reader :vendor

    class << self
      def perform(order_params = {})
        new(get_vendor(order_params[:mch_id])).perform(order_params)
      end

      private

        def get_vendor(mch_id)
          ::WechatVendorPlatformProxy::Vendor.find_by!(mch_id:)
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
    #     openid: ""
    #     attach: ""
    #   }
    def perform(order_params = {})
      unified_order = UnifiedOrderService.perform(order_params)
      { appId: order_params[:appid],
        timeStamp: Time.now.to_i.to_s,
        nonceStr: SecureRandom.hex,
        package: "prepay_id=#{unified_order['prepay_id']}",
        signType: "MD5" }.then { |p| p.merge!(paySign: SignatureService.new(vendor).sign(p)) }
    end
  end
end
