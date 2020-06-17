module WechatVendorPlatformProxy
  module UrlUtility
    def url_with_additional_params(url, params={})
      uri = URI(url)
      new_params = URI.decode_www_form(uri.query || '').reject{|k,v| params.stringify_keys.keys.include?(k)} + params.select{|_,v| v.present? }.to_a
      uri.query = URI.encode_www_form(new_params).presence
      uri.to_s
    end
  end
end
