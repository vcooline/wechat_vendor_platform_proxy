module WechatVendorPlatformProxy
  class ECommerce::ApplymentService < V3::ApiBaseService # rubocop:disable Metrics/ClassLength
    STATE_MAPPING = {
      "CHECKING" => "checking",
      "AUTHORIZING" => "authorizing",
      "ACCOUNT_NEED_VERIFY" => "account_need_verify",
      "AUDITING" => "auditing",
      "REJECTED" => "rejected",
      "NEED_SIGN" => "need_sign",
      "FINISH" => "finish",
      "FROZEN" => "applyment_been_frozen",
      "CANCELED" => "canceled"
    }.freeze

    ORIGINAL_FIELD_KEYS = [
      %w[id_card_info original_id_card_name],
      %w[id_card_info original_id_card_number],
      %w[id_card_info original_id_card_address],
      %w[account_info original_account_name],
      %w[account_info original_account_number],
      %w[contact_info original_contact_name],
      %w[contact_info original_contact_id_card_number],
      %w[contact_info original_mobile_phone],
      %w[contact_info original_contact_email]
    ].freeze

    MEDIA_FIELD_MAPPING = {
      business_license_copy: %w[business_license_info business_license_copy],
      id_card_copy: %w[id_card_info id_card_copy],
      id_card_national: %w[id_card_info id_card_national],
      contact_id_doc_copy: %w[contact_info contact_id_doc_copy],
      contact_id_doc_copy_back: %w[contact_info contact_id_doc_copy_back],
      business_authorization_letter: %w[contact_info business_authorization_letter],
      qualification_uploads: :qualifications,
      business_addition_uploads: :business_addition_pics
    }.freeze

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

    def sync_media_fields(applyment, force: false)
      MEDIA_FIELD_MAPPING.each do |attached_key, field_key|
        attached = applyment.public_send(attached_key)
        last_blob = attached.is_a?(ActiveStorage::Attached::Many) ? attached.blobs.last : attached.blob
        next unless last_blob.present? && (force || (applyment.updated_at - last_blob.created_at) < 1)

        sync_media_field(applyment, field_key, attached)
      end

      applyment.save
    end

    def submit(applyment)
      resp = api_client.post \
        "/v3/ecommerce/applyments/",
        build_api_json(applyment),
        extra_headers: { "Wechatpay-Serial" => vendor.latest_platform_certificate&.serial_no }

      JSON.parse(resp.body).tap do |resp_info|
        applyment.update(applyment_id: resp_info["applyment_id"], state: :submitted) if resp_info["applyment_id"].present?
      end
    end

    def query(applyment) # rubocop:disable Metrics/MethodLength
      resp = api_client.get "/v3/ecommerce/applyments/#{applyment.applyment_id}"

      JSON.parse(resp.body).tap do |resp_info|
        break resp_info unless resp.success?

        update_attrs = resp_info.slice(*%w[sign_url legal_validation_url account_validation audit_detail])
          .merge(
            state: STATE_MAPPING[resp_info["applyment_state"]],
            state_desc: resp_info["applyment_state_desc"],
            sign_state: resp_info["sign_state"]&.downcase,
            sub_mch_id: resp_info["sub_mchid"]
          ).tap do |attrs|
            break attrs if attrs["account_validation"].blank?

            attrs["account_validation"]["account_name"] = cipher.decrypt(attrs["account_validation"]["account_name"])
            attrs["account_validation"]["account_no"].presence&.then do |account_no|
              attrs["account_validation"]["account_no"] = cipher.decrypt(account_no)
            end
          end
        applyment.update update_attrs
      end
    end

    def build_api_json(applyment) # rubocop:disable Metrics/MethodLength
      applyment.slice(
        :out_request_no, :merchant_shortname, :business_addition_desc,
        :business_license_info, :id_card_info, :account_info, :contact_info, :sales_scene_info
      )
        .tap { |h| h.merge!(organization_type: applyment.organization_type_before_type_cast.to_s) }
        .tap { |h| h.merge!({ qualifications: applyment.formatted_qualifications }.compact_blank) }
        .tap { |h| h.merge!({ business_addition_pics: applyment.formatted_business_addition_pics }.compact_blank) }
        .tap { |h| h.delete(:business_license_info) if applyment.organization_type.in?(%w[micro seller]) }
        .tap { |h| h[:contact_info].except!(:contact_id_doc_type, :contact_id_doc_period_begin, :contact_id_doc_period_end) if h.dig(:contact_info, :contact_type).eql?("65") }
        .tap { |h| ORIGINAL_FIELD_KEYS.each { |k| h.dig(*k[0...-1])&.delete(k[-1]) } }
        .tap { |h| h.merge!(owner: true) if applyment.enterprise? }
        .to_json
    end

    private

      def attachment_to_media_id(attached)
        media_file = Tempfile.new(attached.blob.filename.to_s.rpartition(".").then { ["#{_1}.", ".#{_3}"] }, encoding: "ascii-8bit")
          .tap { |f| f.write(attached.download) and f.rewind }
        media_service.upload_image(media_file)["media_id"]
      end

      def sync_media_field(applyment, field_key, attached)
        if attached.is_a?(ActiveStorage::Attached::Many)
          media_ids = attached.map(&method(:attachment_to_media_id)).compact
          applyment.update(field_key => media_ids)
        else
          media_id = attachment_to_media_id(attached).to_s
          applyment.attributes.dig(*field_key[0...-1]).merge!({ field_key[-1] => media_id })
        end
      end
  end
end
