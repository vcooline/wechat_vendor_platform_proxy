class CreateWechatVendorPlatformProxyCapitalPersonalBanks < ActiveRecord::Migration[7.0]
  def change
    create_table :wxpay_capital_personal_banks do |t|
      t.string :account_bank
      t.integer :account_bank_code
      t.string :bank_alias
      t.string :bank_alias_code
      t.boolean :need_bank_branch

      t.timestamps
    end
  end
end
