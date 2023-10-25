module WechatVendorPlatformProxy
  class VerifyFile < ApplicationRecord
    validates :name, presence: true, uniqueness: true
    validates :content, presence: true
  end
end
