module WechatVendorPlatformProxy
  class ECommerce::ApplymentService < V3::ApiBaseService
    ORIGINAL_FIELD_KEYS = [
      %w[id_card_info original_id_card_name],
      %w[id_card_info original_id_card_number],
      %w[account_info original_account_name],
      %w[account_info original_account_number],
      %w[contact_info original_contact_name],
      %w[contact_info original_contact_id_card_number],
      %w[contact_info original_mobile_phone],
      %w[contact_info original_contact_email]
    ].freeze

    MEDIA_FIELD_KEYS = [
      %w[business_license_info business_license_copy_gid],
      %w[id_card_info id_card_copy_gid],
      %w[id_card_info id_card_national_gid],
      %w[qualifications gids],
      %w[business_addition_pics gids]
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
      resp = api_client.post \
        "/v3/ecommerce/applyments/",
        build_api_json(applyment),
        extra_headers: { "Wechatpay-Serial" => vendor.latest_platform_certficate&.serial_no }
      resp_info = JSON.parse(resp.body)

      resp_info["applyment_id"]&.then do |applyment_id|
        applyment.update(applyment_id:)
      end
    end

    def query(applyment)
    end

    def build_api_json(applyment)
      applyment.slice(
        :out_request_no, :merchant_shortname, :business_addition_desc,
        :business_license_info, :id_card_info, :account_info, :contact_info, :sales_scene_info
      )
        .tap { |h| h.merge!(organization_type: applyment.organization_type_before_type_cast.to_s) }
        .tap { |h| h.merge!({ qualifications: applyment.converted_qualifications }.compact_blank) }
        .tap { |h| h.merge!({ business_addition_pics: applyment.converted_business_addition_pics }.compact_blank) }
        .tap { |h| h.delete(:business_license_info) if applyment.organization_type.in?(%w[micro seller]) }
        .tap { |h| ORIGINAL_FIELD_KEYS.each { |k| h.dig(*k[0...-1])&.delete(k[-1]) } }
        .tap { |h| MEDIA_FIELD_KEYS.each { |k| h.dig(*k[0...-1])&.delete(k[-1]) } }
        .tap { |h| h.merge!(need_account_info: true) }
        .tap { |h| h.merge!(owner: true) if applyment.enterprise? }
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
          applyment.attributes.dig(*field_key[0...-1]).merge!({ media_ids => media_ids })
        else
          media_id = gid_to_media_id(field_value).to_s
          applyment.attributes.dig(*field_key[0...-1]).merge!({ field_key[-1].delete_suffix("_gid") => media_id })
        end
      end
  end
end
