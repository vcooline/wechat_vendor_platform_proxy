module WechatVendorPlatformProxy
  class ECommerce::Vendor < ApplicationRecord
    belongs_to :sp_vendor, class_name: "WechatVendorPlatformProxy::Vendor", foreign_key: :sp_mch_id, primary_key: :mch_id, optional: true
    belongs_to :applyment, foreign_key: :sub_mch_id, primary_key: :sub_mch_id, optional: true

    validates_presence_of :sp_mch_id, :sub_mch_id
    validates_uniqueness_of :sub_mch_id

    before_validation :set_initial_attrs, on: :create

    private

      def set_initial_attrs
        self.sp_mch_id ||= applyment.owner.wechat_sp_vendor&.mch_id
      end
  end
end
