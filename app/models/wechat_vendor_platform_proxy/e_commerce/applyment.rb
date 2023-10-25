module WechatVendorPlatformProxy
  class ECommerce::Applyment < ApplicationRecord
    has_one_attached :business_license_copy
    has_one_attached :id_card_copy
    has_one_attached :id_card_national
    has_one_attached :contact_id_doc_copy
    has_one_attached :contact_id_doc_copy_back
    has_one_attached :business_authorization_letter
    has_many_attached :qualification_uploads
    has_many_attached :business_addition_uploads

    belongs_to :owner, polymorphic: true
    has_one :settlement_account, class_name: "WechatVendorPlatformProxy::SettlementAccount", primary_key: :sub_mch_id, foreign_key: :sub_mch_id
    has_one :vendor, class_name: "WechatVendorPlatformProxy::Vendor", foreign_key: :mch_id, primary_key: :sub_mch_id

    enum :state, {
      ready: 0,
      submitted: 3,
      checking: 10,
      authorizing: 15,
      account_need_verify: 20,
      auditing: 30,
      rejected: 40,
      need_sign: 50,
      finish: 60,
      applyment_been_frozen: 70,
      canceled: 80
    }, default: :ready

    enum :organization_type, {
      micro: 2401, # 小微商户，指无营业执照的个人商家。
      seller: 2500, # 个人卖家，指无营业执照，已持续从事电子商务经营活动满6个月，且期间经营收入累计超过20万元的个人商家。（若选择该主体，请在“补充说明”填写相关描述）。
      individual: 4, # 个体工商户，营业执照上的主体类型一般为个体户、个体工商户、个体经营。
      enterprise: 2, # 企业，营业执照上的主体类型一般为有限公司、有限责任公司。
      institution: 3, # 事业单位，包括国内各类事业单位，如：医疗、教育、学校等单位。
      government: 2502, # 政府机关，包括各级、各类政府机关，如机关党委、税务、民政、人社、工商、商务、市监等。
      others: 1708 # 社会组织，包括社会团体、民办非企业、基金会、基层群众性自治组织、农村集体经济组织等组织。
    }

    validates :organization_type, :merchant_shortname, presence: true
    validates :out_request_no, presence: true, uniqueness: true

    before_validation :set_initial_attrs, on: :create
    after_commit :sync_vendor, on: :update

    def formatted_qualifications
      Array(qualifications).to_json
    end

    def formatted_business_addition_pics
      Array(business_addition_pics).to_json
    end

    private

      def set_initial_attrs
        self.out_request_no ||= [DateTime.now.strftime("%Y%m%d%H%M%S"), Random.rand(99999).to_s.rjust(5, "0")].join("_")
        self.business_license_info ||= {}
        self.id_card_info ||= {}
        self.account_info ||= {}
        self.contact_info ||= {}
        self.sales_scene_info ||= {}
        self.qualifications ||= []
        self.business_addition_pics ||= []
      end

      def sync_vendor
        return unless finish? && sub_mch_id.present?

        WechatVendorPlatformProxy::Vendor.ecommerce_vendor.find_or_create_by(mch_id: sub_mch_id)
      end
  end
end
