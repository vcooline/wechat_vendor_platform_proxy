require 'test_helper'

class WechatVendorPlatformProxy::Test < ActiveSupport::TestCase
  test "it should namespaced by module" do
    assert_kind_of Module, WechatVendorPlatformProxy
  end

  test "it should has a version number" do
    assert WechatVendorPlatformProxy::VERSION
  end
end
