module WechatVendorPlatformProxy
  module V3
    class BankService < ApiBaseService
      def personal_list(page: 1, per: 200)
        query_params = { offset: (per * page.pred), limit: per }
        resp = api_client.get "/v3/capital/capitallhh/banks/personal-banking?#{query_params.to_query}"
        JSON.parse(resp.body)
      end

      def sync_personal_list
        bank_infos = []
        (1..).each do |page|
          bank_info = personal_list(page:)
          bank_infos.concat Array(bank_info["data"])

          break if bank_info.dig("links", "next").blank?
        end

        bank_infos.map { |info| Capital::PersonalBank.find_or_create_by info.slice(*%w[account_bank account_bank_code bank_alias bank_alias_code need_bank_branch]) }
          .tap { |banks| Capital::PersonalBank.where.not(id: banks.map(&:id)).destroy_all }
          .then(&:size)
      end

      def corporate_list(page: 1, per: 200)
        query_params = { offset: (per * page.pred), limit: per }
        resp = api_client.get "/v3/capital/capitallhh/banks/corporate-banking?#{query_params.to_query}"
        JSON.parse(resp.body)
      end

      def sync_corporate_list
        bank_infos = []
        (1..).each do |page|
          bank_info = corporate_list(page:)
          bank_infos.concat Array(bank_info["data"])

          break if bank_info.dig("links", "next").blank?
        end

        bank_infos.map { |info| Capital::CorporateBank.find_or_create_by info.slice(*%w[account_bank account_bank_code bank_alias bank_alias_code need_bank_branch]) }
          .tap { |banks| Capital::CorporateBank.where.not(id: banks.map(&:id)).destroy_all }
          .then(&:size)
      end
    end
  end
end
