module WechatVendorPlatformProxy
  class ECommerce::OrderRefundService < V3::ApiBaseService
    %w[
      SYSTEM_ERROR
      USER_ACCOUNT_ABNORMAL
      NOT_ENOUGH
      RESOURCE_NOT_EXISTS
      PARAM_ERROR
      FREQUENCY_LIMITED
      NO_AUTH
      SIGN_ERROR
      INVALID_REQUEST
      MCH_NOT_EXISTS
      REQUEST_BLOCKED
    ].each do |const_name|
      const_set(const_name.underscore.camelize, Class.new(StandardError))
    end

    class << self
      def invoke(method_name, order_params = {})
        new(detect_vendor(order_params[:sp_mch_id])).public_send(method_name, order_params)
      end

      private

        def detect_vendor(mch_id)
          ::WechatVendorPlatformProxy::Vendor.find_by!(mch_id:)
        end
    end

    # order_params example(jsapi):
    # {
    #   sp_appid: "",
    #   sub_mchid: "",
    #   sub_appid: "", # optional
    #   sub_mchid: "",
    #   out_trade_no|transaction_id: "",
    #   out_refund_no: "",
    #   reason: "",
    #   amount: { refund: 0, total: 0, currency: "CNY" },
    #   notify_url: "",
    # }
    def apply(refund_params = {})
      resp = api_client.post "/v3/ecommerce/refunds/apply", refund_params.to_json
      JSON.parse(resp.body).tap do |resp_info|
        handle_api_error(resp_info) unless resp.success?
      end
    end

    def query(sub_mch_id:, out_refund_no: nil, refund_id: nil)
      resp = if out_refund_no.present?
               api_client.get "/v3/ecommerce/refunds/out-refund-no/#{out_refund_no}", { sub_mchid: sub_mch_id }.to_json
             else
               api_client.get "/v3/ecommerce/refunds/id/#{refund_id}", { sub_mchid: }.to_json
             end
      JSON.parse(resp.body).tap do |resp_info|
        handle_api_error(resp_info) unless resp.success?
      end
    end
  end
end
