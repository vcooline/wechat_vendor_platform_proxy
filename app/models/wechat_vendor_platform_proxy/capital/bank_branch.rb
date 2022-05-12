module WechatVendorPlatformProxy
  class Capital::BankBranch < ApplicationRecord
    belongs_to :personal_bank, foreign_key: :bank_alias_code, primary_key: :bank_alias_code, optional: true
    belongs_to :corporate_bank, foreign_key: :bank_alias_code, primary_key: :bank_alias_code, optional: true

    validates_presence_of :bank_alias_code, :bank_branch_name, :bank_branch_id
  end
end
