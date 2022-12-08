require 'test_helper'

module WechatVendorPlatformProxy
  class VendorTest < ActiveSupport::TestCase
    test "should create vendor" do
      vendor = Vendor.new \
        mch_id: "123456",
        type: :normal_vendor

      assert vendor.save
      assert vendor.normal_vendor?
    end

    test "should not create with fee_rate greater than 1" do
      vendor = Vendor.new \
        mch_id: "123456",
        type: :normal_vendor,
        fee_rate: 1.0001

      assert_not vendor.save
      assert vendor.errors[:fee_rate].present?
    end
  end
end
