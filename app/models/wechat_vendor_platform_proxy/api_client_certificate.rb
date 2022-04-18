module WechatVendorPlatformProxy
  class ApiClientCertificate < ApplicationRecord
    belongs_to :vendor

    validates :serial_no, presence: true, uniqueness: true
    validates_presence_of :key, :cert, :effective_at, :expire_at

    before_validation :sync_cert_info, on: :create

    scope :effective, -> { where("effective_at <= :now and expire_at >= :now", now: DateTime.now) }

    def effective?
      DateTime.now.between? effective_at, expire_at
    end

    def sync_cert_info
      OpenSSL::X509::Certificate.new(cert).then do |c|
        self.serial_no = c.serial.to_s(16)
        self.effective_at = c.not_before
        self.expire_at = c.not_after
      end
    end
  end
end
