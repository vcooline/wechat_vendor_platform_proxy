module WechatVendorPlatformProxy
  class Capital::PersonalBanksController < ApplicationController
    def index
      @q = Capital::PersonalBank.ransack(params[:q])
      @banks = @q.result.page(params[:page]).per(params[:per] || 10)
    end
  end
end
