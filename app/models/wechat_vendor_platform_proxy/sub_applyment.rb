module WechatVendorPlatformProxy
  class SubApplyment < ApplicationRecord
    belongs_to :owner, polymorphic: true

    enum :state, {
      ready: 0,
      editting: 10,
      auditing: 20,
      rejected: 30,
      to_be_confirmed: 40,
      to_be_signed: 50,
      signing: 60,
      finished: 70,
      canceled: 80
    }, default: :ready

    validates :business_code, presence: true, uniqueness: true

    before_validation :set_initial_attrs, on: :create

    private

      def set_initial_attrs
        self.business_code ||= [DateTime.now.strftime("%Y%m%d%H%M%S"), Random.rand(99999).to_s.rjust(5, '0')].join("_")
        self.contact_info ||= {}
        self.subject_info ||= {}
        self.business_info ||= {}
        self.settlement_info ||= {}
        self.bank_account_info ||= {}
        self.addition_info ||= {}
      end
  end
end
