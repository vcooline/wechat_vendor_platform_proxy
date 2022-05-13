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

      def province_list
        resp = api_client.get "/v3/capital/capitallhh/areas/provinces"
        JSON.parse(resp.body)
      end

      def city_list(province_code:)
        resp = api_client.get "/v3/capital/capitallhh/areas/provinces/#{province_code}/cities"
        JSON.parse(resp.body)
      end

      def branch_list(bank_alias_code:, city_code:, page: 1, per: 200)
        query_params = { city_code:, offset: (per * page.pred), limit: per }
        resp = api_client.get "/v3/capital/capitallhh/banks/#{bank_alias_code}/branches?#{query_params.to_query}"
        JSON.parse(resp.body)
      end

      def sync_branch_list
        Capital::BankBranch.where.not(bank_alias_code: all_bank_alias_codes).destroy_all

        Array(province_list["data"]).each do |province_info|
          Array(city_list(province_code: province_info["province_code"])["data"]).each do |city_info|
            all_bank_alias_codes.each do |bank_alias_code|
              BankBranchesSyncJob.perform_later(vendor.id, bank_alias_code:, province_info:, city_info:)
            end
          end
        end

        all_bank_alias_codes.size
      end

      def sync_bank_branches(bank_alias_code:, province_info:, city_info:)
        branches = []

        (1..).each do |page|
          paged_result = sync_paged_bank_branches(bank_alias_code:, province_info:, city_info:, page:)
          branches.concat paged_result["branches"]
          break if paged_result.dig("link", "next").blank?
        end

        Capital::BankBranch.where(bank_alias_code:, city_code: city_info["city_code"]).where.not(id: branches.map(&:id)).destroy_all
        branches.size
      end

      private

        def all_bank_alias_codes
          @all_bank_alias_codes ||= [
            *Capital::PersonalBank.need_bank_branch.pluck(:bank_alias_code),
            *Capital::CorporateBank.need_bank_branch.pluck(:bank_alias_code)
          ].uniq
        end

        def sync_paged_bank_branches(bank_alias_code:, province_info:, city_info:, page:)
          branches = []

          resp_info = branch_list(bank_alias_code:, city_code: city_info["city_code"], page:)
          Array(resp_info["data"]).each do |branch_info|
            Capital::BankBranch.find_or_create_by(branch_info.slice(*%w[bank_branch_name bank_branch_id]).merge({ bank_alias_code: }, province_info, city_info))
              .then { |b| branches.push(b) }
          end

          resp_info.slice("link").merge("branches" => branches)
        end
    end
  end
end
