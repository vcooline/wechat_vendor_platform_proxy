module WechatVendorPlatformProxy
  module Marketing
    class MediaService < V3::UploadClient
      def upload_image(image)
        resp = post \
          "/v3/marketing/favor/media/image-upload",
          image,
          extra_headers: { "Wechatpay-Serial" => vendor.latest_platform_certficate&.serial_no }
        JSON.parse(resp.body)
      end
    end
  end
end
