module WechatVendorPlatformProxy
  class Capital::BankBranchesController < ApplicationController
    before_action :set_bank

    def index
      @q = Capital::BankBranch
        .where(bank_alias_code: @bank.bank_alias_code)
        .ransack(params[:q])
      @branches = @q.result.page(params[:page]).per(params[:per] || 10)
    end

    private

      def set_bank
        @bank = Capital::PersonalBank.find_by(bank_alias_code: params[:personal_bank_bank_alias_code]) ||
          Capital::CorporateBank.find_by(bank_alias_code: params[:corporate_bank_bank_alias_code])
      end
  end
end
