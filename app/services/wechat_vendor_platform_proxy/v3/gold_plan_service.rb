module WechatVendorPlatformProxy
  module V3
    class GoldPlanService < ApiBaseService
      def set_gold_plan(sub_mchid, operation_type: "OPEN")
        resp = api_client.post \
          "/v3/goldplan/merchants/changegoldplanstatus",
          { sub_mchid:, operation_type: }.to_json

        JSON.parse(resp.body)
      end

      def set_custom_page(sub_mchid, operation_type: "OPEN")
        resp = api_client.post \
          "/v3/goldplan/merchants/changecustompagestatus",
          { sub_mchid:, operation_type: }.to_json

        JSON.parse(resp.body)
      end

      def set_advertising_filter(sub_mchid, filters: ["E_COMMERCE"])
        resp = api_client.post \
          "/v3/goldplan/merchants/set-advertising-industry-filter",
          { sub_mchid:, advertising_industry_filters: filters }.to_json

        resp.success? ? {} : JSON.parse(resp.body)
      end

      def open_advertising_show(sub_mchid, filters: [])
        resp = api_client.patch \
          "/v3/goldplan/merchants/open-advertising-show",
          { sub_mchid:, advertising_industry_filters: filters }.compact_blank.to_json

        resp.success? ? {} : JSON.parse(resp.body)
      end

      def close_advertising_show(sub_mchid)
        resp = api_client.post \
          "/v3/goldplan/merchants/close-advertising-show",
          { sub_mchid: }.to_json

        resp.success? ? {} : JSON.parse(resp.body)
      end
    end
  end
end
