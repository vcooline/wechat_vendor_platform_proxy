require 'test_helper'

module WechatVendorPlatformProxy
  class ProfitSharingReceiverTest < ActiveSupport::TestCase
    setup do
      @vendor = wechat_vendor_platform_proxy_vendors(:one)
    end

    test "should create personal account with staff relation" do
      receiver = @vendor.profit_sharing_receivers.new \
        account_type: :personal_openid,
        relation_type: :staff,
        app_id: "wx0000000000000001",
        account: "FILLER_abcdefghijklmnopqrstu"

      assert receiver.save
      assert receiver.personal_openid?
      assert receiver.staff?
    end

    test "should unique by vendor and app and account" do
      uniq_receiver = wechat_vendor_platform_proxy_profit_sharing_receivers(:one)
      receiver = @vendor.profit_sharing_receivers.new \
        account_type: :personal_openid,
        relation_type: :staff,
        app_id: uniq_receiver.app_id,
        account: uniq_receiver.account

      assert_not receiver.save
      assert_not_empty receiver.errors[:account]
    end
  end
end
