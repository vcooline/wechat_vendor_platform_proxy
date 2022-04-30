module WechatVendorPlatformProxy
  class BusinessCoupon::WxpayCallbackEventsController < ApplicationController
    skip_before_action :verify_authenticity_token, only: [:create]
    before_action :verify_signature, :set_vendor, only: [:create]

    def create
      logger.info "#{self.class.name} #{self.action_name} params: #{params.to_json}"
      BusinessCoupon::CallbackEventJob.perform_later(@vendor.id, params.permit!)
      head :no_content
    rescue V3::SignatureService::InvalidPlatformSerialNoError, V3::SignatureService::InvalidHeaderSignatureError => e
      logger.error "#{self.class.name} #{self.action_name} #{e.class.name}: #{e.message}"
      render json: { code: "FAIL", message: e.message }, status: :forbidden
    rescue => e
      logger.error "#{self.class.name} #{self.action_name} #{e.class.name}: #{e.message}"
      render json: { code: "FAIL", message: e.message }, status: :unprocessable_entity
    end

    private

      def verify_signature
        V3::SignatureService.verify_authorization_header(request.headers, request.body.tap(&:rewind).read)
      end

      def set_vendor
        @vendor = V3::SignatureService.detect_vendor_by_platform_serial_no(request.headers["Wechatpay-Serial"])
      end
  end
end
