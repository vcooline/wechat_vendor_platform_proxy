module WechatVendorPlatformProxy
  class Capital::CorporateBanksController < ApplicationController
    def index
      @q = Capital::CorporateBank.ransack(params[:q])
      @banks = @q.result.page(params[:page]).per(params[:per] || 10)
    end
  end
end
