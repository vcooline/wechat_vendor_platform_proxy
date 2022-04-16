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

    has_one :latest_api_client_certificate, -> { order(effective_at: :desc, id: :desc) }, class_name: "WechatVendorPlatformProxy::ApiClientCertificate"
    has_one :latest_platform_certficate, -> { order(effective_at: :desc, id: :desc) }, class_name: "WechatVendorPlatformProxy::PlatformCertificate"

    validates :mch_id, presence: true, uniqueness: true
    validates_presence_of :type

    alias_attribute :sign_key, :v2_key

    def to_s
      mch_id
    end

    def api_client_key
      latest_api_client_certificate&.key
    end

    def api_client_cert
      latest_api_client_certificate&.cert
    end
  end
end
