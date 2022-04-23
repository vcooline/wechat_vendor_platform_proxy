module WechatVendorPlatformProxy
  module V3
    class SubApplymentService < ApiBaseService
      INSTITUTION_CERT_TYPES = {
        "事业单位法人证书" => "CERTIFICATE_TYPE_2388"
      }.freeze

      GOVERNMENT_CERT_TYPES = {
        "统一社会信用代码证书" => "CERTIFICATE_TYPE_2389"
      }.freeze

      OTHERS_CERT_TYPES = {
        "统一社会信用代码证书" => "CERTIFICATE_TYPE_2389",
        "社会团体法人登记证书" => "CERTIFICATE_TYPE_2394",
        "民办非企业单位登记证书" => "CERTIFICATE_TYPE_2395",
        "基金会法人登记证书" => "CERTIFICATE_TYPE_2396",
        "慈善组织公开募捐资格证书" => "CERTIFICATE_TYPE_2397",
        "农民专业合作社法人营业执照" => "CERTIFICATE_TYPE_2398",
        "宗教活动场所登记证" => "CERTIFICATE_TYPE_2399",
        "其他证书/批文/证明" => "CERTIFICATE_TYPE_2400"
      }.freeze

      ID_HOLDER_TYPE = {
        "法人" => "LEGAL",
        "经办人" => "SUPER"
      }.freeze

      ID_DOC_TYPE = {
        "中国大陆居民-身份证" => "DENTIFICATION_TYPE_IDCARD",
        "其他国家或地区居民-护照" => "DENTIFICATION_TYPE_OVERSEA_PASSPORT",
        "中国香港居民-来往内地通行证" => "DENTIFICATION_TYPE_HONGKONG_PASSPORT",
        "中国澳门居民-来往内地通行证" => "DENTIFICATION_TYPE_MACAO_PASSPORT",
        "中国台湾居民-来往大陆通行证" => "DENTIFICATION_TYPE_TAIWAN_PASSPORT"
      }.freeze

      SALES_SCENES_TYPE = {
        "线下场所" => "SALES_SCENES_STORE",
        "公众号" => "SALES_SCENES_MP"
        # "小程序" => "SALES_SCENES_MINI_PROGRAM",
        # "互联网网站" => "SALES_SCENES_WEB",
        # "APP" => "SALES_SCENES_APP",
        # "企业微信" => "SALES_SCENES_WEWORK"
      }.freeze

      INDIVIDUAL_BANK_ACCOUNT_TYPE = {
        "个人银行卡" => "BANK_ACCOUNT_TYPE_PERSONAL",
        "对公银行账户" => "BANK_ACCOUNT_TYPE_CORPORATE"
      }.freeze

      ELSE_BANK_ACCOUNT_TYPE = {
        "对公银行账户" => "BANK_ACCOUNT_TYPE_CORPORATE"
      }.freeze

      def sync_media_ids(applyment, changes)
        # TODO
      end

      def sync_encrypt_fields(applyment, changes)
        # TODO
      end

      def submit(applyment)
        # TODO
      end

      def query(applyment)
        # TODO
      end
    end
  end
end
