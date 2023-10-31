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
  task :sync_platform_certificates, [] => %i[environment set_logger] do |_tasks, _args|
    Rails.logger.info "Sync wechat pay platform certficates START."

    WechatVendorPlatformProxy::Vendor.find_each do |vendor|
      WechatVendorPlatformProxy::V3::PlatformCertificateService.new(vendor).sync
    end

    Rails.logger.info "Sync wechat pay platform certficates END."
  end

  desc "Sync wechat pay bank list"
  task :sync_bank_list, [] => %i[environment set_logger] do |_tasks, _args|
    Rails.logger.info "Sync wechat pay bank list START."

    WechatVendorPlatformProxy::Vendor.first&.then do |vendor|
      service = WechatVendorPlatformProxy::V3::BankService.new(vendor)
      service.sync_corporate_list
      service.sync_personal_list
      service.sync_branch_list
    end

    Rails.logger.info "Sync wechat pay bank list END."
  end
end
