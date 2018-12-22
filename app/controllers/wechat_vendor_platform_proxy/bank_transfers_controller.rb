require_dependency "wechat_vendor_platform_proxy/application_controller"

module WechatVendorPlatformProxy
  class BankTransfersController < ApplicationController
    def show
    end

    def create
      raise "TODO: check remote ip whitelist; verify params sign with app client sign key; then perform transfer"
    end

    private
      def bank_transfer_params
        params.fetch(:bank_transfer, {})
      end
  end
end
