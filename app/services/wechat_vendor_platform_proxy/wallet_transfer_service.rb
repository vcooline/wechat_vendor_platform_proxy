module WechatVendorPlatformProxy
  class WalletTransferService
    attr_reader :vendor

    class << self
      def perform(transfer_params={})
        new(get_vendor(transfer_params[:mchid])).perform(transfer_params)
      end

      def fetch_info(query_params={})
        new(get_vendor(query_params[:mch_id])).fetch_info(query_params)
      end

      private
        def get_vendor(mch_id)
          ::WechatVendorPlatformProxy::Vendor.find_by!(mch_id: mch_id)
        end
    end

    def initialize(vendor)
      @vendor = vendor
    end

    # transfer_params example:
    #   {
    #     mch_appid: "",
    #     mchid: "",
    #     partner_trade_no: "",
    #     openid: "",
    #     amount: 1.00,
    #     desc: ""
    #   }
    def perform(transfer_params={})
      request_params = generate_transfer_params(transfer_params)
      call_transfer_api(request_params)
    end

    # query_params example:
    #   {
    #     mch_id: "",
    #     appid: "",
    #     partner_trade_no: "",
    #   }
    def fetch_info(query_params={})
      request_params = generate_query_params(query_params)
      call_query_api(request_params)
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

      def generate_transfer_params(base_params)
        base_params.reverse_merge(
          check_name: "NO_CHECK",
          spbill_create_ip: Socket.ip_address_list.detect{|intf| intf.ipv4_private?}.ip_address,
          nonce_str: SecureRandom.hex
        ).tap { |p| p[:sign] = sign_params(p) }
      end

      def call_transfer_api(request_params)
        Rails.logger.info "WechatVendorPlatformProxy WalletTransferService call transfer api reqt: #{request_params.to_json}"
        resp = ssl_api_client.post "https://api.mch.weixin.qq.com/mmpaymkttransfers/promotion/transfers", request_params.to_xml(dasherize: false)
        Rails.logger.info "WechatVendorPlatformProxy WalletTransferService call transfer api resp(#{resp.status}):\n#{resp.body.squish}"
        Hash.from_xml(resp.body)["xml"]
      end

      def generate_query_params(base_params)
        base_params.reverse_merge(
          nonce_str: SecureRandom.hex
        ).tap { |p| p[:sign] = sign_params(p) }
      end

      def call_query_api(request_params)
        Rails.logger.info "WechatVendorPlatformProxy WalletTransferService call query api reqt: #{request_params.to_json}"
        resp = ssl_api_client.post "https://api.mch.weixin.qq.com/mmpaymkttransfers/gettransferinfo", request_params.to_xml(dasherize: false)
        Rails.logger.info "WechatVendorPlatformProxy WalletTransferService call query api resp(#{resp.status}):\n#{resp.body.squish}"
        Hash.from_xml(resp.body)["xml"]
      end
  end
end
