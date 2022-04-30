require "kaminari"
require "jbuilder"
require "faraday"
require "faraday/multipart"

module WechatVendorPlatformProxy
  class Engine < ::Rails::Engine
    isolate_namespace WechatVendorPlatformProxy

    initializer :append_migrations do |app|
      unless app.root.to_s.match root.to_s
        config.paths["db/migrate"].expanded.each do |expanded_path|
          app.config.paths["db/migrate"] << expanded_path
        end
      end
    end

    config.generators do |g|
      g.orm             :active_record
      g.template_engine :erb
      g.stylesheets     false
      g.javascripts     false
      g.helper          false
      g.test_framework  nil
      g.skip_routes     true
    end
  end
end
