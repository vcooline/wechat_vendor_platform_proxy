module WechatVendorPlatformProxy
  class Vendor < ApplicationRecord
    self.inheritance_column = nil

    enum :type, {
      normal_vendor: 1,
      service_provider: 2,
      sub_vendor: 3,
      micro_vendor: 4
    }

    has_many :api_client_certificates, dependent: :destroy
    has_many :platform_certificates, dependent: :destroy

    has_one :latest_api_client_certificate, -> { order(end_at: :desc, id: :desc) }, class_name: "WechatVendorPlatformProxy::ApiClientCertificate"
    has_one :latest_platform_certficates, -> { order(end_at: :desc, id: :desc) }, class_name: "WechatVendorPlatformProxy::PlatformCertificate"

    validates :mch_id, presence: true, uniqueness: true
    validates_presence_of :type

    def to_s
      mch_id
    end
  end
end
