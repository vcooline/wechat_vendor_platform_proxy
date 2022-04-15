module WechatVendorPlatformProxy
  class PlatformCertificate < ApplicationRecord
    belongs_to :vendor

    validates :serial_no, presence: true, uniqueness: true
    validates_presence_of :cert
  end
end
