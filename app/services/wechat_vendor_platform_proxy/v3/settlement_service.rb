module WechatVendorPlatformProxy
  module V3
    class SettlementService < ApiBaseService
      IncorrectBankAccountNumberError = Class.new StandardError

      def get_settlement(sub_mch_id = nil)
        resp = api_client.get "/v3/apply4sub/sub_merchants/#{sub_mch_id}/settlement"
        JSON.parse(resp.body)
      end

      def sync_settlement(settlement_account)
        get_settlement(settlement_account.sub_mch_id).tap do |resp_info|
          break resp_info if resp_info["code"].present?
          raise IncorrectBankAccountNumberError unless settlement_account.account_number.end_with?(resp_info["account_number"].last(2))

          settlement_account.update \
            resp_info.slice(*%w[account_typ account_bank bank_name bank_branch_id verify_result verify_fail_reason]).merge({
              state: (resp_info["verify_result"] == "VERIFY_SUCCESS" ? "success" : nil)
            }.compact_blank)
        end
      end

      def modify_settlement(settlement_account)
        resp = api_client.post \
          "/v3/apply4sub/sub_merchants/#{settlement_account.sub_mch_id}/modify-settlement",
          build_api_json(settlement_account),
          extra_headers: { "Wechatpay-Serial" => vendor.latest_platform_certficate&.serial_no }

        if resp.success?
          settlement_account.submitted!
          {}
        else
          JSON.parse(resp.body)
        end
      end

      def build_api_json(settlement_account)
        settlement_account.slice(:account_type, :account_bank, :bank_address_code, :bank_name, :bank_branch_id)
          .tap { |h| h.merge!(account_number: cipher.encrypt(settlement_account.account_number.to_s)) }
          .compact_blank
          .to_json
      end
    end
  end
end
