module WechatVendorPlatformProxy
  class V3::NormalOrderService < V3::ApiBaseService
    %w[
      TRADE_ERROR
      SYSTEM_ERROR
      SIGN_ERROR
      RULE_LIMIT
      PARAM_ERROR
      OUT_TRADE_NO_USED
      ORDER_NOT_EXIST
      ORDER_CLOSED
      OPENID_MISMATCH
      NOT_ENOUGH
      NO_AUTH
      MCH_NOT_EXISTS
      INVALID_TRANSACTIONID
      INVALID_REQUEST
      FREQUENCY_LIMITED
      BANK_ERROR
      APPID_MCHID_NOT_MATCH
      ACCOUNT_ERROR
    ].each do |const_name|
      const_set(const_name.underscore.camelize, Class.new(StandardError))
    end

    class << self
      def invoke(method_name, order_params = {})
        new(detect_vendor(order_params[:mch_id])).public_send(method_name, order_params)
      end

      private

        def detect_vendor(mch_id)
          ::WechatVendorPlatformProxy::Vendor.find_by!(mch_id:)
        end
    end

    # order_params example(jsapi):
    #   {
    #     appid: "",
    #     mchid: "",
    #     description: "",
    #     out_trade_no: "",
    #     time_expire: "", # optional
    #     attach: "", # optional
    #     notify_url: "",
    #     goods_tag: "", # optional,
    #     amount: { total: 0, currency: "CNY" },
    #     payer: { openid: "" }, # sp_openid, sub_openid must have one
    #     detail: { cost_price: "", invoice_id: "", goods_detail: [] }, # optional
    #     scene_info: { payer_client_ip: "", device_id: "", store_info: { id: "", name: "", area_code: "", address: "" } } # optional
    #     settle_info: { profit_sharing: true|false }, # optional
    #   }
    %i[jsapi].each do |order_type|
      define_method "build_#{order_type}_order" do |order_params = {}|
        resp = api_client.post "/v3/pay/transactions/#{order_type}", order_params.to_json
        JSON.parse(resp.body).tap do |resp_info|
          raise ("WechatVendorPlatformProxy::V3::NormalOrderService::#{resp_info['code'].underscore.camelize}".safe_constantize || StandardError), resp_info["message"] unless resp.success?
        end
      end
    end

    def build_jsapi_config(order_params = {})
      unified_order = build_jsapi_order(order_params)

      {
        appId: (order_params[:sp_appid].presence || order_params[:sub_appid]),
        timeStamp: Time.now.to_i.to_s,
        nonceStr: SecureRandom.hex,
        package: "prepay_id=#{unified_order['prepay_id']}",
        signType: "RSA"
      }.then { |config| config.merge(paySign: signer.sign(*config.values_at(:appId, :timeStamp, :nonceStr, :package))) }
    end
  end
end
