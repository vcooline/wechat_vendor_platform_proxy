module WechatVendorPlatformProxy
  class ECommerce::NormalOrderService < V3::ApiBaseService
    %w[
      TRADE_ERROR
      SYSTEMERROR
      SIGN_ERROR
      RULELIMIT
      PARAM_ERROR
      OUT_TRADE_NO_USED
      ORDERNOTEXIST
      ORDER_CLOSED
      OPENID_MISMATCH
      NOTENOUGH
      NOAUTH
      MCH_NOT_EXISTS
      INVALID_TRANSACTIONID
      INVALID_REQUEST
      FREQUENCY_LIMITED
      BANKERROR
      APPID_MCHID_NOT_MATCH
      ACCOUNTERROR
    ].each do |const_name|
      const_set(const_name.underscore.camelize, Class.new(StandardError))
    end

    class << self
      def invoke(method_name, order_params = {})
        new(detect_vendor(order_params[:sp_mch_id])).public_send(method_name, order_params)
      end

      def verify_notification_sign(notification_params = {})
        SignatureService.verify_notification_sign(notification_params)
      end

      private

        def detect_vendor(mch_id)
          ::WechatVendorPlatformProxy::Vendor.find_by!(mch_id:)
        end
    end

    # order_params example(jsapi):
    #   {
    #     sp_appid: "",
    #     sp_mchid: "",
    #     sub_appid: "", # optional
    #     sub_mchid: "",
    #     description: "",
    #     out_trade_no: "",
    #     time_expire: "", # optional
    #     attach: "", # optional
    #     notify_url: "",
    #     goods_tag: "", # optional,
    #     settle_info: { profit_sharing: true|false, subsidy_amount: 0 }, # optional
    #     amount: { total: 0, currency: "CNY" },
    #     payer: { sp_openid: "", sub_openid: ""}, # sp_openid, sub_openid must have one
    #     detail: { cost_price: "", invoice_id: "", goods_detail: [] }, # optional
    #     scene_info: { payer_client_ip: "", device_id: "", store_info: { id: "", name: "", area_code: "", address: "" } } # optional
    #   }
    %i[jsapi].each do |order_type|
      define_method "build_#{order_type}_order" do |order_params = {}|
        resp = api_client.post "/v3/pay/partner/transactions/jsapi", order_params.to_json
        JSON.parse(resp.body).tap do |resp_info|
          raise ("WechatVendorPlatformProxy::ECommerce::NormalOrderService::#{resp_info['code'].underscore.camelize}".safe_constantize || StandardError), resp_info["message"] unless resp.success?
        end
      end
    end
  end
end
