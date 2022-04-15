module WechatVendorPlatformProxy
  class PlatformCertificate < ApplicationRecord
    belongs_to :vendor

    validates :serial_no, presence: true, uniqueness: true
    validates_presence_of :cert

    scope :effective, -> { where("effective_at <= :now and expire_at >= :now", now: DateTime.now) }

    def effective?
      DateTime.now.between? effective_at, expire_at
    end
  end
end
