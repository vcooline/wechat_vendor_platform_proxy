module WechatVendorPlatformProxy
  class ApiClientCertificate < ApplicationRecord
    belongs_to :vendor

    validates :serial_no, presence: true, uniqueness: true
    validates_presence_of :key, :cert
  end
end
