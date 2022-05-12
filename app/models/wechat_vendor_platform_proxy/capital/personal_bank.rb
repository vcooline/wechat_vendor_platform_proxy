module WechatVendorPlatformProxy
  class Capital::PersonalBank < ApplicationRecord
    has_many :bank_branches, foreign_key: :bank_alias_code, primary_key: :bank_alias_code

    validates_presence_of :account_bank, :account_bank_code, :bank_alias, :bank_alias_code

    scope :need_bank_branch, -> { where(need_bank_branch: true) }

    def to_param
      bank_alias_code
    end
  end
end
