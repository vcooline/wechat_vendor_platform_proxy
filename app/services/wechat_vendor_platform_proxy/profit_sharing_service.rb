module WechatVendorPlatformProxy
  class ProfitSharingService
    %w(SYSTEMERROR AMOUNT_OVERDUE RECEIVER_INVALID INVALID_TRANSACTIONID PARAM_ERROR INVALID_REQUEST OPENID_MISMATCH FREQUENCY_LIMITED ORDER_NOT_READY NOAUTH NOT_SHARE_ORDER RECEIVER_HIGH_RISK).each do |err_code|
      const_set err_code.to_sym, Class.new(StandardError)
    end

    attr_reader :vendor

    class << self
      def call(profit_sharing_params={})
        raise "Not implemented"
      end

      def query_ratio(query_ratio_params={})
        new(get_vendor(query_ratio_params[:mch_id])).query_ratio(query_ratio_params)
      end

      private
        def get_vendor(mch_id)
          ::WechatVendorPlatformProxy::Vendor.find_by!(mch_id: mch_id)
        end
    end

    def initialize(vendor)
      @vendor = vendor
    end

    def perform(profit_sharing_params={})
      raise "Not implemented"
    end

    # query_ratio_params example:
    #   {
    #     mch_id: "",
    #     sub_mch_id: "",
    #   }
    def query_ratio(query_ratio_params={})
      request_params = query_ratio_params.reverse_merge(
        nonce_str: SecureRandom.hex,
        sign_type: "HMAC-SHA256"
      ).tap { |p| p[:sign] = SignatureService.new(vendor).sign(p) }
      Rails.logger.info "WechatVendorPlatformProxy ProfitSharingService call query_ratio api reqt: #{request_params.to_json}"
      resp = Faraday.post "https://api.mch.weixin.qq.com/pay/profitsharingmerchantratioquery", request_params.to_xml(dasherize: false)
      Rails.logger.info "WechatVendorPlatformProxy ProfitSharingService call query_ratio api resp(#{resp.status}): #{resp.body.squish.force_encoding('UTF-8')}"
      Hash.from_xml(resp.body)["xml"]
    end
  end
end
