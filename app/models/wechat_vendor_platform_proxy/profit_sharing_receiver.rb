module WechatVendorPlatformProxy
  class ProfitSharingReceiver < ApplicationRecord
    belongs_to :vendor

    enum :account_type, {
      merchant_id: 10,
      personal_openid: 20
    }

    enum :relation_type, {
      store_itself: 1, # 门店
      staff: 2, # 员工
      store_owner: 3, # 店主
      partner: 4, # 合作伙伴
      headquarter: 5, # 总部
      brand: 6, # 品牌方
      distributor: 7, # 分销商
      user: 8, # 用户
      supplier: 9, # 供应商
      custom: 10 # 自定义
    }

    validates :app_id, :account_type, :account, :relation_type, presence: true
    validates :account, uniqueness: { scope: %i[vendor_id app_id] }
  end
end
