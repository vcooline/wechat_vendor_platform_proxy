module WechatVendorPlatformProxy
  module V3
    class BankBranchesSyncJob < ApplicationJob
      queue_as :batch

      def perform(vendor_id, bank_alias_code:, province_info:, city_info:)
        Vendor.find_by(id: vendor_id)&.then do |vendor|
          BankService.new(vendor).sync_bank_branches(bank_alias_code:, province_info:, city_info:)
        end
      end
    end
  end
end
