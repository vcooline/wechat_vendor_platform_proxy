module WechatVendorPlatformProxy
  class V3::BatchTransferService < V3::ApiBaseService
    %w[
      SYSTEM_ERROR
      APPID_MCHID_NOT_MATCH
      PARAM_ERROR
      INVALID_REQUEST
      NO_AUTH
      NOT_ENOUGH
      ACCOUNTERROR
      QUOTA_EXCEED
      NOT_FOUND
      FREQUENCY_LIMITED
    ].each do |const_name|
      const_set(const_name.underscore.camelize, Class.new(StandardError))
    end

    class << self
      def invoke(method_name, transfer_params = {})
        new(detect_vendor(transfer_params[:mch_id])).public_send(method_name, transfer_params)
      end

      private

        def detect_vendor(mch_id)
          ::WechatVendorPlatformProxy::Vendor.find_by!(mch_id:)
        end
    end

    # transfer_params example:
    # {
    #   appid: "",
    #   out_batch_no: "",
    #   batch_name: "",
    #   batch_remark: "",
    #   total_amount: 0,
    #   total_num: 1,
    #   transfer_detail_list: [
    #     {out_detail_no: "",
    #      transfer_amount: 0,
    #      transfer_remark: "",
    #      openid: ""
    #     }
    #   ]
    # }
    # transfer response example:
    # {
    #   batch_id: "",
    #   create_time: "",
    #   out_batch_no: ""
    # }
    def apply(transfer_params = {})
      resp = api_client.post "/v3/transfer/batches", transfer_params.to_json
      JSON.parse(resp.body).tap do |resp_info|
        handle_api_error(resp_info) unless resp.success?
      end
    end

    def query_batch(out_batch_no:, need_query_detail: true, offset: 0, limit: 100, detail_status: "ALL")
      resp = api_client.get "/v3/transfer/batches/out-batch-no/#{out_batch_no}?#{{need_query_detail:, offset:, limit:, detail_status:}.to_query}"
      JSON.parse(resp.body).tap do |resp_info|
        handle_api_error(resp_info) unless resp.success?
      end
    end

    def query_transfer(out_batch_no:, out_detail_no:)
      resp = api_client.get "/v3/transfer/batches/out-batch-no/#{out_batch_no}/details/out-detail-no/#{out_detail_no}"
      JSON.parse(resp.body).tap do |resp_info|
        handle_api_error(resp_info) unless resp.success?
      end
    end
  end
end
