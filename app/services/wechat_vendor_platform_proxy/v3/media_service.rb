module WechatVendorPlatformProxy
  module V3
    class MediaService < ApiBaseService
      def upload_image(image)
        resp = upload_client.post("/v3/merchant/media/upload", image)
        JSON.parse(resp.body)
      end

      def upload_video(video)
        raise "To be implemented"
      end
    end
  end
end
