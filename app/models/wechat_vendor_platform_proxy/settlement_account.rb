module WechatVendorPlatformProxy
  class SettlementAccount < ApplicationRecord
    belongs_to :ecommerce_applyment, class_name: "WechatVendorPlatformProxy::ECommerce::Applyment", primary_key: :sub_mch_id, foreign_key: :sub_mch_id, optional: true
    belongs_to :sub_applyment, primary_key: :sub_mch_id, foreign_key: :sub_mch_id, optional: true

    enum :state, {
      ready: 0,
      submitted: 10,
      success: 60
    }, default: :ready

    validates_presence_of :account_type, :account_bank, :bank_address_code, :account_number
    validates :sub_mch_id, presence: true, uniqueness: true
  end
end
