module WechatVendorPlatformProxy
  class V3::OrderRefundService < V3::ApiBaseService
    %w[
      SYSTEM_ERROR
      RESOURCE_NOT_EXISTS
      PARAM_ERROR
      FREQUENCY_LIMITED
      NO_AUTH
      SIGN_ERROR
      INVALID_REQUEST
      MCH_NOT_EXISTS
      USER_ACCOUNT_ABNORMAL
      NOT_ENOUGH
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

    # refund_params example:
    # {
    #   out_trade_no|transaction_id: "",
    #   out_refund_no: "",
    #   reason: "",
    #   amount: { refund: 0, total: 0, currency: "CNY" },
    #   notify_url: "",
    # }
    def apply(refund_params = {})
      resp = api_client.post "/v3/refund/domestic/refunds", refund_params.to_json
      JSON.parse(resp.body).tap do |resp_info|
        handle_api_error(resp_info) unless resp.success?
      end
    end

    def query(out_refund_no:)
      resp = api_client.get "/v3/refund/domestic/refunds/#{out_refund_no}"
      JSON.parse(resp.body).tap do |resp_info|
        handle_api_error(resp_info) unless resp.success?
      end
    end
  end
end
