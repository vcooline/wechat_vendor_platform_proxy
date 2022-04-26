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

    accepts_nested_attributes_for :latest_api_client_certificate # for use as unpersisted temporary data
    accepts_nested_attributes_for :api_client_certificates, allow_destroy: true
    accepts_nested_attributes_for :platform_certificates, allow_destroy: true

    after_commit :trigger_platform_certificate_sync

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

    private

      def trigger_platform_certificate_sync
        V3::PlatformCertificateSyncJob.perform_later(self.id)
      end
  end
end
