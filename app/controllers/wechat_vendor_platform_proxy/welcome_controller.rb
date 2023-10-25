module WechatVendorPlatformProxy
  class WelcomeController < ApplicationController
    def index; end

    def verify_file
      render plain: VerifyFile.find_by(name: params[:wechat_vendor_platform_verify_file])&.content
    end
  end
end
