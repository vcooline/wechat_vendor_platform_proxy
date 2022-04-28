module WechatVendorPlatformProxy
  module Marketing
    class BusinessCouponService < V3::ApiBaseService
      def create_stock(stock)
        resp = api_client.post \
          "/v3/marketing/busifavor/stocks",
          build_create_stock_json(stock)

        JSON.parse(resp.body)
      end

      def update_stock_budget(stock, target_max_coupons: nil, current_max_coupons: nil)
        resp = api_client.patch \
          "/v3/marketing/busifavor/stocks/#{stock.stock_id}/budget",
          build_update_stock_budget_json(stock, target_max_coupons:, current_max_coupons:)

        JSON.parse(resp.body).tap do |resp_info|
          stock.stock_send_rule.merge!({ max_coupons: resp_info["max_coupons"]&.nonzero? }.compact_blank)
          stock.save
        end
      end

      def update_stock_info(stock)
        resp = api_client.patch \
          "/v3/marketing/busifavor/stocks/#{stock.stock_id}",
          build_update_stock_info_json(stock)

        resp.status == 204
      end

      def get_stock(stock)
        resp = api_client.get "/v3/marketing/busifavor/stocks/#{stock.stock_id}"
        JSON.parse(resp.body)
      end

      def sync_stock(stock)
        get_stock(stock).then do |stock_info|
          %w[coupon_use_rule custom_entrance display_pattern_info notify_config send_count_information stock_send_rule].each do |field_key|
            stock.attributes[field_key].deep_merge!(stock_info[field_key])
          end
          stock.stock_state = stock_info["stock_state"].downcase
          stock.save
        end

        stock
      end

      private

        def build_create_stock_json(stock)
          stock.attributes.slice(
            "out_request_no", "belong_merchant", "stock_name", "goods_name",
            "coupon_code_mode", "coupon_use_rule", "stock_send_rule", "custom_entrance", "display_pattern_info", "notify_config"
          ).merge(
            stock_type: stock.stock_type.upcase, coupon_code_mode: stock.coupon_code_mode.upcase
          )
            .tap { |attrs| attrs.dig("coupon_use_rule", "coupon_available_time")&.slice!("available_begin_time", "available_end_time") }
            .tap { |attrs| attrs["display_pattern_info"]&.slice!("description", "background_color", "coupon_image_url", "prevent_api_abuse") }
            .to_json
        end

        def build_update_stock_budget_json(stock, target_max_coupons: nil, current_max_coupons: nil)
          {
            target_max_coupons: (target_max_coupons || stock.stock_send_rule["max_coupons"]),
            current_max_coupons: (current_max_coupons || stock.stock_send_rule["max_coupons"]),
            modify_budget_request_no: "#{stock.belong_merchant}#{DateTime.now.strftime('%Y%m%d%H%M%S%L')}"
          }.compact_blank.to_json
        end

        def build_update_stock_info_json(stock)
          stock.attributes.slice(
            "out_request_no", "stock_name", "goods_name",
            "coupon_use_rule", "stock_send_rule", "custom_entrance", "display_pattern_info", "notify_config"
          )
            .tap { |attrs| attrs["coupon_use_rule"].slice!("use_method") }
            .tap { |attrs| attrs["stock_send_rule"].slice!("prevent_api_abuse") }
            .tap { |attrs| attrs["display_pattern_info"].delete("finder_info") }
            .to_json
        end
    end
  end
end
