class MigrateWechatVendorPlatformProxyApiCerts < ActiveRecord::Migration[7.0]
  def up
    WechatVendorPlatformProxy::Vendor.find_each do |vendor|
      next unless vendor.attributes["api_client_key"].present?

      vendor.api_client_certificates.find_or_create_by \
        key: vendor.attributes["api_client_key"],
        cert: vendor.attributes["api_client_cert"]
    end

    remove_column :wxpay_vendors, :api_client_key
    remove_column :wxpay_vendors, :api_client_cert
  end

  def down
    add_column :wxpay_vendors, :api_client_key, :text
    add_column :wxpay_vendors, :api_client_cert, :text
  end
end
