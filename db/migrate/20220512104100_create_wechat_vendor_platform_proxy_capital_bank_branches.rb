class CreateWechatVendorPlatformProxyCapitalBankBranches < ActiveRecord::Migration[7.0]
  def change
    create_table :wxpay_capital_bank_branches do |t|
      t.string :bank_alias_code
      t.string :bank_branch_name
      t.string :bank_branch_id

      t.string :province_name
      t.string :province_code
      t.string :city_name
      t.string :city_code

      t.timestamps
    end
  end
end
