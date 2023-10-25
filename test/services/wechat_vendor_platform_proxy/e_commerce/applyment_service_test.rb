require "test_helper"

module WechatVendorPlatformProxy::ECommerce
  class ApplymentServiceTest < ActiveSupport::TestCase
    setup do
      @sp_vendor = wechat_vendor_platform_proxy_vendors(:sp_two)
      @applyment = wechat_vendor_platform_proxy_e_commerce_applyments(:one)

      stub_request(:post, "https://api.mch.weixin.qq.com/v3/merchant/media/upload")
        .to_return(status: 200, body: {media_id: "FILLER"}.to_json)
    end

    test "should sync has one attached fields" do
      ApplymentService.new(@sp_vendor).sync_media_fields(@applyment, force: true)

      assert_not_empty @applyment.business_license_info["business_license_copy"]
    end

    test "should sync has many attached fields" do
      ApplymentService.new(@sp_vendor).sync_media_fields(@applyment, force: true)

      assert_not_empty @applyment.qualifications
    end
  end
end
