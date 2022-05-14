module WechatVendorPlatformProxy
  module Ownable
    extend ActiveSupport::Concern

    included do
      has_many :wxpay_sub_applyments, class_name: "::WechatVendorPlatformProxy::SubApplyment", as: :owner, dependent: :destroy
      has_many :wxpay_ecommerce_applyments, class_name: "::WechatVendorPlatformProxy::ECommerce::Applyment", as: :owner, dependent: :destroy
    end
  end
end
