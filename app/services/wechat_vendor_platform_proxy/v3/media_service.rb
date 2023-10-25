module WechatVendorPlatformProxy
  module V3
    class MediaService < UploadClient
      def upload_image(image)
        resp = post \
          "/v3/merchant/media/upload",
          image,
          extra_headers: { "Wechatpay-Serial" => vendor.latest_platform_certficate&.serial_no }
        JSON.parse(resp.body)
      end

      def upload_video(_video)
        raise "To be implemented"
      end
    end
  end
end
