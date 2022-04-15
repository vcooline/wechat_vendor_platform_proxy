$stdout.sync = true

namespace :wechat_vendor_platform_proxy do
  desc "Set logger"
  task set_logger: :environment do
    Rails.logger = ActiveSupport::Logger.new "log/wechat_vendor_platform_tasks.log"
    Rails.logger.formatter = proc { |severity, datetime, _progname, msg| "[#{datetime.strftime('%F %T')}] #{severity}: #{msg}\n" }
    ActiveRecord::Base.logger = Rails.logger
    ActiveRecord::Base.logger.level = :debug
  end

  desc "Sync wechat pay platform certficates"
  task :sync_platform_certificates, [] => [:environment, :set_logger] do |_tasks, _args|
    Rails.logger.info "Sync wechat pay platform certficates START."

    WechatVendorPlatformProxy::Vendor.find_each do |vendor|
      WechatVendorPlatformProxy::V3::PlatformCertificateService.new(vendor).sync
    end

    Rails.logger.info "Sync wechat pay platform certficates END."
  end
end
