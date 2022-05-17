class CreateWechatVendorPlatformProxySettlementAccounts < ActiveRecord::Migration[7.0]
  def change
    create_table :wxpay_settlement_accounts do |t|
      t.string :sub_mch_id, index: true
      t.string :account_type
      t.string :account_bank
      t.string :bank_address_code
      t.string :bank_name
      t.string :bank_branch_id
      t.string :account_number
      t.string :verify_result
      t.text :verify_fail_reason

      t.integer :state

      t.timestamps
    end
  end
end
