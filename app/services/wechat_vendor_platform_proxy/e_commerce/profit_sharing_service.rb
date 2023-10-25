module WechatVendorPlatformProxy
  class ECommerce::ProfitSharingService < V3::ApiBaseService
    %w[
      SYSTEM_ERROR
      PARAM_ERROR
      INVALID_REQUEST
      FREQUENCY_LIMITED
      RULE_LIMIT
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
    #     appid: "",
    #     sub_mchid: "",
    #     transaction_id: "",
    #     out_order_no: "",
    #     finish: true|false,
    #     receivers: [
    #       {
    #         type: "",
    #         receiver_account: "",
    #         name: "",
    #         amount: "",
    #         description: ""
    #       }
    #     ]
    #   }
    #
    # response example:
    #   {
    #     "sub_mchid" => "1900000109",
    #     "transaction_id"=>"4200001675202211152950185452",
    #     "out_order_no"=>"202211151309312",
    #     "order_id"=>"30002406752022111538979401576",
    #     "state"=>"PROCESSING",
    #     "receivers"=> [
    #       {
    #         "account"=>"ow-xxx-xxxxxxxx-xxxxxx-xxxxx",
    #         "amount"=>1,
    #         "create_time"=>"2022-11-15T13:17:49+08:00",
    #         "description"=>"Debug demo",
    #         "detail_id"=>"36002406752022111554361823897",
    #         "finish_time"=>"2022-11-15T13:18:20+08:00",
    #         "result"=>"PENDING",
    #         "type"=>"PERSONAL_OPENID"
    #       }
    #     ]
    #   }
    def apply(order_params = {})
      resp = api_client.post "v3/ecommerce/profitsharing/orders", order_params.to_json
      parse_resp_with_error_handling(resp)
    end

    # response example:
    #   {
    #     "sub_mchid": "1900000109",
    #     "transaction_id": "4208450740201411110007820472",
    #     "out_order_no": "P20150806125346",
    #     "order_id": "3008450740201411110007820472",
    #     "state": "FINISHED",
    #     "receivers": [
    #       {
    #         "receiver_mchid": "1900000110",
    #         "amount": 100,
    #         "description": "分给商户1900000110",
    #         "type": "MERCHANT_ID",
    #         "result": "SUCCESS",
    #         "receiver_account": "1900000109",
    #         "detail_id": "36011111111111111111111",
    #         "fail_reason": "ACCOUNT_ABNORMAL",
    #         "create_time": "2015-05-20T13:29:35+08:00",
    #         "finish_time": "2015-05-20T13:29:35+08:00"
    #       }
    #     ],
    #     "finish_amount": 100,
    #     "finish_description": "分账完结"
    #   }
    def query(sub_mchid:, transaction_id:, out_order_no:)
      resp = api_client.get "/v3/ecommerce/profitsharing/orders?#{{ sub_mchid:, transaction_id:, out_order_no: }.to_query}"
      parse_resp_with_error_handling(resp)
    end

    # unfreeze_params example:
    #   {
    #     sub_mchid: "",
    #     transaction_id: "微信支付订单号"
    #     out_order_no: "同一分账单号多次请求等同一次"
    #     description: "解冻全部剩余资金"
    #   }
    # => {"sub_mchid": "1900000109", "transaction_id": "4208450740201411110007820472", "out_order_no": "P20150806125346", "order_id": "3008450740201411110007820472"}
    def unfreeze(unfreeze_params = {})
      resp = api_client.post "/v3/ecommerce/profitsharing/finish-order", unfreeze_params.to_json
      parse_resp_with_error_handling(resp)
    end

    # => {"transaction_id"=>"", "unsplit_amount"=>1000}
    def query_remain_amount(transaction_id:)
      resp = api_client.get "/v3/ecommerce/profitsharing/orders/#{transaction_id}/amounts"
      parse_resp_with_error_handling(resp)
    end

    # receiver_params example:
    #   {
    #     appid: "",
    #     type: "",
    #     account: "",
    #     name: "", # optional
    #     encrypted_name: "", # optional
    #     relation_type: ""
    #   }
    # => {"account"=>"ow-xxx-xxxxxxxx-xxxxxx-xxxxx", "type"=>"PERSONAL_OPENID"}
    # TODO: handle vendor receiver count exceed 20000(max). should delete earliest by updated_at and retry specific error by retriable for n times
    def add_receiver(receiver_params = {})
      resp = api_client.post "/v3/ecommerce/profitsharing/receivers/add", receiver_params.to_json
      resp_info = parse_resp_with_error_handling(resp)

      vendor.profit_sharing_receivers.find_or_initialize_by(app_id: receiver_params[:appid], account: resp_info["account"]).tap do |receiver|
        receiver.update!({
          account_type: resp_info["type"].downcase,
          name: receiver_params[:name],
          relation_type: receiver_params[:relation_type].downcase
        }.compact_blank)
      end
    end

    # 删除分账接收方
    # receiver_params example:
    #   {
    #     appid: "",
    #     type: "",
    #     account: "",
    #   }
    # => {"account"=>"ow-xxx-xxxxxxxx-xxxxxx-xxxxx", "type"=>"PERSONAL_OPENID"}
    def delete_receiver(receiver_params = {})
      resp = api_client.post "/v3/ecommerce/profitsharing/receivers/delete", receiver_params.to_json
      resp_info = parse_resp_with_error_handling(resp)

      vendor.profit_sharing_receivers.find_by(app_id: receiver_params[:appid], account: resp_info["account"])&.tap(&:destroy!)
    end
  end
end
