module WechatVendorPlatformProxy
  class VerifyFile < ApplicationRecord
    validates :name, presence: true, uniqueness: true
    validates_presence_of :content
  end
end
