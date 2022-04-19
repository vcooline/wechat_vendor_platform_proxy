module WechatVendorPlatformProxy
  class ApiClientCertificate < ApplicationRecord
    belongs_to :vendor

    validates :serial_no, presence: true, uniqueness: true
    validates_presence_of :key, :cert, :effective_at, :expire_at

    before_validation :sync_cert_info, on: :create
    validate :must_match_vendor_mch_id

    scope :effective, -> { where("effective_at <= :now and expire_at >= :now", now: DateTime.now) }

    delegate :mch_id, to: :vendor

    def effective?
      DateTime.now.between? effective_at, expire_at
    end

    def match_vendor_mch_id?
      parsed_mch_id = OpenSSL::X509::Certificate.new(cert).subject.to_a.detect { |e| e[0].eql?("CN") }[1]
      parsed_mch_id == mch_id
    end

    def sync_cert_info
      OpenSSL::X509::Certificate.new(cert).then do |c|
        self.serial_no = c.serial.to_s(16)
        self.effective_at = c.not_before
        self.expire_at = c.not_after
      end
    end

    private

      def must_match_vendor_mch_id
        errors.add(:cert, "Must match vendor mch_id") unless match_vendor_mch_id?
      end
  end
end
