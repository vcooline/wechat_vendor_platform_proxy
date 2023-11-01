module WechatVendorPlatformProxy
  module V3
    class SettlementService < ApiBaseService
      %w[
        PARAM_ERROR
        INVALID_REQUEST
        SIGN_ERROR
        SYSTEM_ERROR
        NO_AUTH
      ].each do |const_name|
        const_set(const_name.underscore.camelize, Class.new(StandardError))
      end

      IncorrectBankAccountNumberError = Class.new StandardError

      def query_settlement(sub_mch_id)
        resp = api_client.get "/v3/apply4sub/sub_merchants/#{sub_mch_id}/settlement"
        parse_resp_with_error_handling(resp)
      end

      def sync_settlement(sub_mch_id)
        account_info = query_settlement(sub_mch_id)

        SettlementAccount.find_or_initialize_by(sub_mch_id:).tap do |account|
          account.account_number ||= account.applyment&.account_info&.dig("original_account_number")
          raise IncorrectBankAccountNumberError unless account.account_number&.end_with?(account_info["account_number"].last(2))

          account.update \
            account_info.slice(*%w[account_type account_bank bank_name bank_branch_id verify_result verify_fail_reason]).merge({
              state: (account_info["verify_result"] == "VERIFY_SUCCESS" ? "success" : nil)
            }.compact_blank)
        end
      end

      def modify_settlement(settlement_account)
        resp = api_client.post \
          "/v3/apply4sub/sub_merchants/#{settlement_account.sub_mch_id}/modify-settlement",
          build_api_json(settlement_account),
          extra_headers: { "Wechatpay-Serial" => vendor.latest_platform_certficate&.serial_no }

        if resp.success?
          settlement_account.tap(&:submitted!)
        else
          parse_resp_with_error_handling(resp)
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
