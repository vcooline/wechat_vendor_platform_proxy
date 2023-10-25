require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)
require "wechat_vendor_platform_proxy"

module Dummy
  class Application < Rails::Application
    config.before_configuration do
      env_file = Rails.root.join("config/local_env.yml").to_s
      if File.file?(env_file)
        YAML.load_file(env_file, aliases: true)[Rails.env].to_h.each do |key, value|
          ENV[key.to_s] = value.to_s
        end
      end
    end

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults Rails::VERSION::STRING.to_f

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    config.time_zone = "Beijing"
    config.i18n.available_locales = %i[zh-CN en]
    config.i18n.default_locale = :"zh-CN"
    config.i18n.fallbacks = {
      CN: :"zh-CN",
      "zh-HK": :"zh-CN",
      "zh-TW": :"zh-CN",
      "en-US": :en,
      "en-BG": :en,
      "en-CA": :en,
      "en-AU": :en
    }

    config.action_mailer.smtp_settings = {
      address: ENV.fetch("action_mailer_smtp_address", nil),
      port: ENV.fetch("action_mailer_smtp_port", nil),
      domain: ENV.fetch("action_mailer_smtp_domain", nil),
      user_name: ENV.fetch("action_mailer_smtp_user_name", nil),
      password: ENV.fetch("action_mailer_smtp_password", nil),
      authentication: "plain"
    }
    config.action_mailer.preview_path = "#{WechatVendorPlatformProxy::Engine.root}/test/mailers/previews"
  end
end
