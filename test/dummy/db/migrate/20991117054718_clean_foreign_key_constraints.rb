class CleanForeignKeyConstraints < ActiveRecord::Migration[7.0]
  def change
    remove_foreign_key :active_storage_attachments, to_table: :active_storage_blobs, column: :blob_id
    remove_foreign_key :active_storage_variant_records, to_table: :active_storage_blobs, column: :blob_id
    remove_foreign_key :wxpay_api_client_certificates, to_table: :wxpay_vendors, column: :vendor_id
    remove_foreign_key :wxpay_platform_certificates, to_table: :wxpay_vendors, column: :vendor_id
  end
end
