module WechatVendorPlatformProxy
  class RefundQueryService
    attr_reader :vendor

    class << self
      def perform(refund_params={})
        new(get_vendor(refund_params[:sub_mch_id] || refund_params[:mch_id])).perform(refund_params)
      end

      private
        def get_vendor(mch_id)
          ::WechatVendorPlatformProxy::Vendor.find_by!(mch_id: mch_id)
        end
    end

    def initialize(vendor)
      @vendor = vendor
    end

    # refund_params example:
    #   {
    #     appid: "",
    #     mch_id: "",
    #     out_refund_no|out_trade_no: "",
    #     offset: 0
    #   }
    def perform(refund_params={})
      request_params = generate_refund_params(refund_params)
      call_refund_query_api(request_params)
    end

    private
      def sign_params(p)
        Digest::MD5.hexdigest(p.sort.map{|k, v| "#{k}=#{v}" }.join("&").to_s + "&key=#{vendor.sign_key}").upcase
      end

      def generate_refund_params(base_params)
        base_params.reverse_merge(
          nonce_str: SecureRandom.hex
        ).tap { |p| p[:sign] = sign_params(p) }
      end

      def call_refund_query_api(request_params)
        Rails.logger.info "WechatVendorPlatformProxy RefundQueryService call refund query api reqt: #{request_params.to_json}"
        resp = Faraday.post "https://api.mch.weixin.qq.com/pay/refundquery", request_params.to_xml(dasherize: false)
        Rails.logger.info "WechatVendorPlatformProxy RefundQueryService call refund query api resp(#{resp.status}): #{resp.body.squish}"
        Hash.from_xml(resp.body)["xml"]
      end
  end
end
