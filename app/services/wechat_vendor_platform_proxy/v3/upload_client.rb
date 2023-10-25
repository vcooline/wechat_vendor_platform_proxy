module WechatVendorPlatformProxy
  module V3
    class UploadClient < VendorBaseService
      API_GATEWAY = "https://api.mch.weixin.qq.com".freeze

      def post(...)
        api_call("POST", ...)
      end

      private

        def connection(http_method, fullpath, meta, extra_headers: {})
          Faraday.new(API_GATEWAY) do |conn|
            conn.request :multipart
            conn.request :url_encoded
            conn.adapter :net_http
            conn.headers = {
              "Content-Type": "multipart/form-data",
              Accept: "application/json",
              Authorization: SignatureService.new(vendor).build_authorization_header(http_method, fullpath, meta)
            }.merge(extra_headers).compact
          end
        end

        def api_call(http_method, fullpath, file, extra_headers: {})
          file_path = file.is_a?(String) ? file : file.path
          # mime_type = MIME::Types.of(file_path).detect { |mt| mt.media_type.in?(%w[image voice video thumb]) }.to_s
          mime_type = Rack::Mime.mime_type(File.extname(file_path))
          meta = { filename: File.basename(file), sha256: Digest::SHA256.hexdigest(File.read(file)) }.to_json

          Rails.logger.info "#{self.class.name} #{http_method} #{fullpath} reqt: #{meta}"
          resp = connection(http_method, fullpath, meta, extra_headers:)
            .public_send(http_method.downcase, fullpath, { file: Faraday::Multipart::FilePart.new(file_path, mime_type), meta: })
          Rails.logger.info "#{self.class.name} #{http_method} #{fullpath} resp(#{resp.status}): #{resp.body.squish}"

          resp
        end
    end
  end
end
