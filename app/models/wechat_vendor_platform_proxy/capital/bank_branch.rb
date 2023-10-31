module WechatVendorPlatformProxy
  class Capital::BankBranch < ApplicationRecord
    belongs_to :personal_bank, foreign_key: :bank_alias_code, primary_key: :bank_alias_code, optional: true
    belongs_to :corporate_bank, foreign_key: :bank_alias_code, primary_key: :bank_alias_code, optional: true

    validates :bank_alias_code, :bank_branch_name, :bank_branch_id, :province_name, :city_name, presence: true

    def self.ransackable_attributes(_auth_object = nil)
      %w[bank_alias_code bank_branch_name bank_branch_id province_name province_code city_name city_code]
    end

    def self.ransackable_associations(_auth_object = nil)
      %w[personal_bank corporate_bank]
    end
  end
end
