module WechatVendorPlatformProxy
  class Vendor < ApplicationRecord
    self.inheritance_column = nil

    validates :mch_id, presence: true, uniqueness: true
    validates_presence_of :type

    enum :type, {
      normal_vendor: 1,
      service_provider: 2,
      sub_vendor: 3
    }

    def to_s
      mch_id
    end
  end
end
