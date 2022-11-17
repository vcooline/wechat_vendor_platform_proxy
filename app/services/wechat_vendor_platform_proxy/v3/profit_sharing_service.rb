module WechatVendorPlatformProxy
  class V3::ProfitSharingService < V3::ApiBaseService
    %w[
      SYSTEM_ERROR
      PARAM_ERROR
      INVALID_REQUEST
      FREQUENCY_LIMITED
      NO_AUTH
      NOT_ENOUGH
      RESOURCE_NOT_EXISTS
      RATELIMIT_EXCEED
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

    # order_params example:
    #   {
    #     mchid: "",
    #     appid: "",
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
    def apply(order_params = {})
      resp = api_client.post "/v3/profitsharing/orders", {appid: Hash(payment.properties)["app_id"], transaction_id: Hash(payment.properties)["wxpay_transaction_id"], out_order_no: "NEW-UNIQUE-ID", unfreeze_unsplit: false, receivers: [{type: "PERSONAL_OPENID", account: "ow-a8s-aNkW2Yrx-VJ1r1H-a90vg", amount: 1, description: "Debug demo"}]}.to_json
# {
#   "order_id"=>"30002406752022111538979401576",
#   "out_order_no"=>"202211151309312",
#   "receivers"=>
#   [{"account"=>"ow-a8s-aNkW2Yrx-VJ1r1H-a90vg",
#     "amount"=>1,
#     "create_time"=>"2022-11-15T13:17:49+08:00",
#     "description"=>"Debug demo",
#     "detail_id"=>"36002406752022111554361823897",
#     "finish_time"=>"2022-11-15T13:18:20+08:00",
#     "result"=>"SUCCESS",
#     "type"=>"PERSONAL_OPENID"}],
#     "state"=>"FINISHED",
#     "transaction_id"=>"4200001675202211152950185452"
# }
    end

    def query
    end

    def unfreeze
    end

    def query_remain_amount
    end

    def add_receiver
    end

    def delete_receiver
    end

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
        appId: order_params[:appid].presence,
        timeStamp: Time.now.to_i.to_s,
        nonceStr: SecureRandom.hex,
        package: "prepay_id=#{unified_order['prepay_id']}",
        signType: "RSA"
      }.then { |config| config.merge(paySign: signer.sign(*config.values_at(:appId, :timeStamp, :nonceStr, :package))) }
    end
  end
end

# 请求分账

# 添加分账接收方API
# resp = api_client.post "/v3/profitsharing/receivers/add", {appid: Hash(payment.properties)["app_id"], type: "PERSONAL_OPENID", account: 'ow-a8s-aNkW2Yrx-VJ1r1H-a90vg', name: nil, relation_type: "USER" }.to_json
#  => {"account"=>"ow-a8s-aNkW2Yrx-VJ1r1H-a90vg", "relation_type"=>"USER", "type"=>"PERSONAL_OPENID"} 


# 删除分账接收方
# resp = api_client.post "/v3/profitsharing/receivers/delete", {appid: Hash(payment.properties)["app_id"], type: "PERSONAL_OPENID", account: 'ow-a8s-aNkW2Yrx-VJ1r1H-a90vg' }.to_json
#  => {"account"=>"ow-a8s-aNkW2Yrx-VJ1r1H-a90vg", "type"=>"PERSONAL_OPENID"} 

# 查询剩余待分金额
# resp=api_client.get "/v3/profitsharing/transactions/#{Hash(payment.properties)['wxpay_transaction_id']}/amounts"
