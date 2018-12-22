Rails.application.routes.draw do
  mount WechatVendorPlatformProxy::Engine => "/wechat_vendor_platform_proxy"
end
