module WechatVendorPlatformProxy
  class RefundApplyService
    %w(SYSTEMERROR BIZERR_NEED_RETRY TRADE_OVERDUE ERROR USER_ACCOUNT_ABNORMAL INVALID_REQ_TOO_MUCH NOTENOUGH INVALID_TRANSACTIONID FREQUENCY_LIMITED).each do |err_code|
      const_set err_code.to_sym, Class.new(StandardError)
    end

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
    #     out_trade_no: "",
    #     out_refund_no: "",
    #     total_fee: "",
    #     refund_fee: "",
    #     refund_desc: "",
    #     notify_url: ""
    #   }
    def perform(refund_params={})
      request_params = generate_refund_params(refund_params)
      call_refund_api(request_params)
    end

    private
      def ssl_api_client
        ssl_client_key = OpenSSL::PKey::RSA.new vendor.api_client_key
        ssl_client_cert = OpenSSL::X509::Certificate.new vendor.api_client_cert
        Faraday.new(ssl: {client_key: ssl_client_key, client_cert: ssl_client_cert}, headers: {'Content-Type' => 'application/xml'})
      end

      def sign_params(p)
        Digest::MD5.hexdigest(p.sort.map{|k, v| "#{k}=#{v}" }.join("&").to_s + "&key=#{vendor.sign_key}").upcase
      end

      def generate_refund_params(base_params)
        base_params.reverse_merge(
          nonce_str: SecureRandom.hex
        ).tap { |p| p[:sign] = sign_params(p) }
      end

      def call_refund_api(request_params)
        Rails.logger.info "WechatVendorPlatformProxy RefundApplyService call refund api reqt: #{request_params.to_json}"
        resp = ssl_api_client.post "https://api.mch.weixin.qq.com/secapi/pay/refund", request_params.to_xml(dasherize: false)
        Rails.logger.info "WechatVendorPlatformProxy RefundApplyService call refund api resp(#{resp.status}): #{resp.body.squish}"
        Hash.from_xml(resp.body)["xml"]
      end
  end
end
