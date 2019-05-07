module WechatVendorPlatformProxy
  class DownloadFundFlowService
    attr_reader :vendor

    class << self
      def perform(order_params={})
        new(get_vendor(order_params[:mch_id])).perform(order_params)
      end

      private
        def get_vendor(mch_id)
          ::WechatVendorPlatformProxy::Vendor.find_by!(mch_id: mch_id)
        end
    end

    def initialize(vendor)
      @vendor = vendor
    end

    # order_params example:
    #   {
    #     appid: "",
    #     mch_id: "",
    #     bill_date: ""
    #     account_type: ""
    #   }
    def perform(order_params={})
      request_params = generate_order_params(order_params)
      call_download_api(request_params)
    end

    private
      def ssl_api_client
        ssl_client_key = OpenSSL::PKey::RSA.new vendor.api_client_key
        ssl_client_cert = OpenSSL::X509::Certificate.new vendor.api_client_cert
        Faraday.new(ssl: {client_key: ssl_client_key, client_cert: ssl_client_cert}, headers: {'Content-Type' => 'application/xml'})
      end

      def sign_params(p)
        OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), vendor.sign_key, p.sort.map{|k, v| "#{k}=#{v}" }.join("&").to_s+"&key=#{vendor.sign_key}").upcase
      end

      def generate_order_params(base_params)
        base_params.reverse_merge(
          nonce_str: SecureRandom.hex,
          bill_date: Date.yesterday.strftime("%Y%m%d"),
          account_type: "Basic"
        ).tap { |p| p[:sign] = sign_params(p) }
      end

      def call_download_api(request_params)
        Rails.logger.info "WechatVendorPlatformProxy DownloadFundFlowService call download api reqt: #{request_params.to_json}"
        resp = ssl_api_client.post "https://api.mch.weixin.qq.com/pay/downloadfundflow", request_params.to_xml(dasherize: false), {"Content-Type": "application/xml"}
        Rails.logger.info "WechatVendorPlatformProxy DownloadFundFlowService call download api resp(#{resp.status})"
        resp.body
      end
  end
end



