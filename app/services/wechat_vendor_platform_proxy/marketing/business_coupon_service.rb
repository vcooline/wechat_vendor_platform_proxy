module WechatVendorPlatformProxy
  module Marketing
    class BusinessCouponService < V3::ApiBaseService
      def callback_url
        resp = api_client.get "/v3/marketing/busifavor/callbacks?mchid=#{vendor.mch_id}"

        JSON.parse(resp.body)
      end

      def callback_url=(url = nil)
        raise ArgumentError, "url is not valid." if url.present? && !/\A#{URI::DEFAULT_PARSER.make_regexp(['https'])}\z/.match?(url)

        resp = api_client.post \
          "/v3/marketing/busifavor/callbacks",
          {
            mchid: vendor.mch_id,
            notify_url: (url || WechatVendorPlatformProxy::Engine.routes.url_helpers.business_coupon_wxpay_callback_events_url(host: ENVConfig.app_frontend_base_url, protocol: "https"))
          }.to_json

        JSON.parse(resp.body)
      end
      alias_method :set_callback_url, :callback_url=

      def create_stock(stock)
        resp = api_client.post \
          "/v3/marketing/busifavor/stocks",
          build_create_stock_json(stock)

        JSON.parse(resp.body).tap do |resp_info|
          if resp_info["stock_id"].present?
            stock.update stock_id: resp_info["stock_id"], state: :unaudit
            BusinessCoupon::StockSyncJob.set(wait: 1.minute).perform_later(stock.id)
          end
          set_callback_url(nil) if BusinessCoupon::Stock.where(vendor:).where.not(id: stock.id).exists?
        end
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
        resp.success? ? JSON.parse(resp.body) : nil
      end

      def sync_stock(stock)
        get_stock(stock)&.then do |stock_info|
          %w[coupon_use_rule custom_entrance display_pattern_info notify_config send_count_information stock_send_rule].each do |field_key|
            stock.attributes[field_key].deep_merge!(stock_info[field_key])
          end
          stock.stock_state = stock_info["stock_state"].underscore
          stock.save
          stock
        end
      end

      def receive_coupon_url(coupon)
        query_params = {
          stock_id: coupon.stock_id,
          out_request_no: "#{coupon.stock.belong_merchant}#{coupon.created_at.strftime('%Y%m%d%H%M%S')}#{coupon.id}",
          send_coupon_merchant: coupon.stock.belong_merchant,
          open_id: coupon.open_id,
          coupon_code: coupon.code
        }.tap { |q| q[:sign] = v2_sign(q.slice(:stock_id, :out_request_no, :send_coupon_merchant, :open_id, :coupon_code)) }

        "https://action.weixin.qq.com/busifavor/getcouponinfo?#{query_params.to_query}#wechat_redirect"
      end

      def get_coupon(coupon)
        resp = api_client.get "/v3/marketing/busifavor/users/#{coupon.open_id}/coupons/#{coupon.code}/appids/#{coupon.app_id}"
        resp.success? ? JSON.parse(resp.body) : nil
      end

      def sync_coupon(coupon)
        get_coupon(coupon)&.then do |coupon_info|
          coupon.assign_attributes \
            coupon_info.slice(*%w[stock_name goods_name receive_time available_start_time expire_time coupon_use_rule deactivate_request_no deactivate_reason]).compact_blank
          coupon.state = coupon_info["coupon_state"].underscore
          coupon.save
          coupon
        end
      end

      def use_coupon(coupon)
        resp = api_client.post \
          "/v3/marketing/busifavor/coupons/use",
          build_use_coupon_json(coupon)

        JSON.parse(resp.body).tap do |resp_info|
          resp_info["wechatpay_use_time"]&.then { |use_time| coupon.update(state: :used, use_time:) }
        end
      end

      def return_coupon(coupon)
        resp = api_client.post \
          "/v3/marketing/busifavor/coupons/return",
          { coupon_code: coupon.code, stock_id: coupon.stock_id, return_request_no: coupon.return_request_no }.to_json

        JSON.parse(resp.body).tap do |resp_info|
          resp_info["wechatpay_return_time"]&.then { |return_time| coupon.update(state: :sended, return_time:) }
        end
      end

      def deactivate_coupon(coupon, reason: nil)
        resp = api_client.post \
          "/v3/marketing/busifavor/coupons/deactivate",
          {
            coupon_code: coupon.code, stock_id: coupon.stock_id,
            deactivate_request_no: coupon.deactivate_request_no,
            deactivate_reason: reason.presence || coupon.deactivate_reason
          }.compact.to_json

        JSON.parse(resp.body).tap do |resp_info|
          resp_info["wechatpay_deactivate_time"]&.then { |deactivate_time| coupon.update(state: :deactivated, deactivate_time:) }
        end
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

        def build_use_coupon_json(coupon)
          {
            coupon_code: coupon.code,
            use_request_no: coupon.use_request_no,
            stock_id: coupon.stock_id,
            appid: coupon.app_id,
            openid: coupon.open_id,
            use_time: DateTime.now.rfc3339
          }.to_json
        end

        def v2_sign(sign_params)
          WechatVendorPlatformProxy::SignatureService.new(vendor).sign sign_params, sign_type: "HMAC-SHA256"
        end
    end
  end
end
