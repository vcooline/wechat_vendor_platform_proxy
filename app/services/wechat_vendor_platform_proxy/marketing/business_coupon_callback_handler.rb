module WechatVendorPlatformProxy
  module Marketing
    class BusinessCouponCallbackHandler < V3::ApiBaseService
      def perform(event_params)
        resource_params = JSON.parse cipher.decrypt(**event_params["resource"].slice("ciphertext", "nonce", "associated_data").symbolize_keys)

        case event_params["event_type"]
        when "COUPON.SEND"
          handle_coupon_send_event(resource_params)
        end
      end

      private

        def handle_coupon_send_event(resource_params)
          BusinessCoupon::Coupon.find_by(code: resource_params["coupon_code"])&.then do |coupon|
            coupon.update! \
              receive_time: resource_params["send_time"],
              state: (coupon.ready? ? :sended : coupon.state)
          end
        end
    end
  end
end
