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
        "中国大陆居民-身份证" => "IDENTIFICATION_TYPE_IDCARD",
        "其他国家或地区居民-护照" => "IDENTIFICATION_TYPE_OVERSEA_PASSPORT",
        "中国香港居民-来往内地通行证" => "IDENTIFICATION_TYPE_HONGKONG_PASSPORT",
        "中国澳门居民-来往内地通行证" => "IDENTIFICATION_TYPE_MACAO_PASSPORT",
        "中国台湾居民-来往大陆通行证" => "IDENTIFICATION_TYPE_TAIWAN_PASSPORT"
      }.freeze

      SALES_SCENES_TYPE = {
        "线下场所" => "SALES_SCENES_STORE",
        "公众号" => "SALES_SCENES_MP"
        # "小程序" => "SALES_SCENES_MINI_PROGRAM",
        # "互联网网站" => "SALES_SCENES_WEB",
        # "APP" => "SALES_SCENES_APP",
        # "企业微信" => "SALES_SCENES_WEWORK"
      }.freeze

      MICRO_BANK_ACCOUNT_TYPE = {
        "个人银行卡" => "BANK_ACCOUNT_TYPE_PERSONAL"
      }.freeze

      INDIVIDUAL_BANK_ACCOUNT_TYPE = {
        "个人银行卡" => "BANK_ACCOUNT_TYPE_PERSONAL",
        "对公银行账户" => "BANK_ACCOUNT_TYPE_CORPORATE"
      }.freeze

      ELSE_BANK_ACCOUNT_TYPE = {
        "对公银行账户" => "BANK_ACCOUNT_TYPE_CORPORATE"
      }.freeze

      ORIGINAL_FIELD_KEYS = [
        %w[contact_info original_contact_name],
        %w[contact_info original_contact_id_numbe],
        %w[contact_info original_mobile_phone],
        %w[contact_info original_contact_email],
        %w[subject_info identity_info id_card_info original_id_card_name],
        %w[subject_info identity_info id_card_info original_id_card_number],
        %w[bank_account_info original_account_name],
        %w[bank_account_info original_account_number]
      ].freeze

      MEDIA_FIELD_KEYS = [
        %w[subject_info business_license_info license_copy_gid],
        %w[subject_info certificate_info cert_copy_gid],
        %w[subject_info certificate_letter_copy_gid],
        %w[subject_info identity_info id_card_info id_card_copy_gid],
        %w[subject_info identity_info id_card_info id_card_national_gid],
        %w[business_info sales_info biz_store_info store_entrance_pic_gids],
        %w[business_info sales_info biz_store_info indoor_pic_gids],
        %w[business_info sales_info mp_info mp_pics_gids],
        %w[settlement_info qualifications_gids],
        %w[addition_info business_addition_pics_gids]
      ].freeze

      def sync_media_fields(applyment, changes = {}, force: false)
        MEDIA_FIELD_KEYS.each do |field_key|
          prev, curr = *[0, 1].map { |idx| changes.dig(field_key[0], idx, *field_key[1..]) }
          curr ||= applyment.attributes.dig(*field_key) if force
          next if curr.blank? || (curr.eql?(prev) && !force)

          sync_media_field(applyment, field_key, curr)
        end

        applyment.save
      end

      def sync_encrypt_fields(applyment, changes = {}, force: false)
        ORIGINAL_FIELD_KEYS.each do |field_key|
          prev, curr = *[0, 1].map { |idx| changes.dig(field_key[0], idx, *field_key[1..]) }
          curr ||= applyment.attributes.dig(*field_key) if force
          next if curr.blank? || (curr.eql?(prev) && !force)

          encrypted_value = cipher.encrypt(curr)
          applyment.attributes.dig(*field_key[0...-1]).merge!({ field_key[-1].delete_prefix("original_") => encrypted_value })
        end

        applyment.save
      end

      def submit(applyment)
        resp = api_client.post "/v3/applyment4sub/applyment/", build_api_json(applyment)
        resp_info = JSON.parse(resp.body)

        resp_info["applyment_id"]&.then do |applyment_id|
          applyment.update(applyment_id:)
        end
      end

      def query(applyment)
      end

      def build_api_json(applyment)
        applyment.slice(:business_code, :contact_info, :subject_info, :business_info, :settlement_info, :bank_account_info, :addition_info)
          .tap { |h| h.deep_merge!({ subject_info: { identity_info: { owner: applyment.subject_info.dig("identity_info", "owner").to_i.positive? } } }) }
          .tap { |h| ORIGINAL_FIELD_KEYS.each { |k| h.dig(*k[0...-1])&.delete(k[-1]) } }
          .tap { |h| MEDIA_FIELD_KEYS.each { |k| h.dig(*k[0...-1])&.delete(k[-1]) } }
          .then(&method(:slice_subject_keys))
          .to_json
      end

      private

        def gid_to_media_id(gid)
          GlobalID::Locator.locate(gid)&.then do |obj|
            media_file = Tempfile.new(obj.name.rpartition(".").then{ ["#{_1}.", ".#{_3}"] }, encoding: 'ascii-8bit')
              .tap { |f| f.write(URI.parse(Addressable::URI.parse(obj.private_url).normalize).read) and f.rewind }
            media_service.upload_image(media_file)["media_id"]
          end
        end

        def sync_media_field(applyment, field_key, field_value)
          if field_value.is_a?(Array)
            media_ids = field_value.map(&method(:gid_to_media_id)).compact
            applyment.attributes.dig(*field_key[0...-1]).merge!({ field_key[-1].delete_suffix("_gids") => media_ids })
          else
            media_id = gid_to_media_id(field_value).to_s
            applyment.attributes.dig(*field_key[0...-1]).merge!({ field_key[-1].delete_suffix("_gid") => media_id })
          end
        end

        def slice_subject_keys(data = {})
          case data.dig("subject_info", "subject_type")
          when "SUBJECT_TYPE_MICRO"
            data["subject_info"].slice!("subject_type", "micro_biz_info", "identity_info")
            case data.dig("subject_info", "micro_biz_info", "micro_biz_type")
            when "MICRO_TYPE_STORE"
              data.dig("subject_info", "micro_biz_info").slice!("micro_biz_type", "micro_store_info")
            when "MICRO_TYPE_MOBILE"
              data.dig("subject_info", "micro_biz_info").slice!("micro_biz_type", "micro_mobile_info")
            when "MICRO_TYPE_ONLINE"
              data.dig("subject_info", "micro_biz_info").slice!("micro_biz_type", "micro_online_info")
            end
          when "SUBJECT_TYPE_INDIVIDUAL", "SUBJECT_TYPE_ENTERPRISE"
            data["subject_info"].slice!("subject_type", "business_license_info", "identity_info")
          when "SUBJECT_TYPE_INSTITUTIONS", "SUBJECT_TYPE_GOVERNMENT", "SUBJECT_TYPE_OTHERS"
            data["subject_info"].slice!("subject_type", "certificate_info", "identity_info")
          end

          data
        end
    end
  end
end
