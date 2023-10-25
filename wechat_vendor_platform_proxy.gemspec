require_relative "lib/wechat_vendor_platform_proxy/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "wechat_vendor_platform_proxy"
  spec.version     = WechatVendorPlatformProxy::VERSION
  spec.authors     = ["Andersen Fan"]
  spec.email       = ["as181920@gmail.com"]
  spec.homepage    = ""
  spec.summary     = "Wechat vendor platform proxy engine"
  spec.description = "api proxies for vendors"
  spec.license     = "MIT"

  spec.metadata["allowed_push_host"] = "https://gems.dd-life.com"

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "faraday"
  spec.add_dependency "faraday-multipart"
  spec.add_dependency "jbuilder"
  spec.add_dependency "kaminari"
  spec.add_dependency "rails", ">= 7.0"
  spec.add_dependency "ransack"
  spec.metadata["rubygems_mfa_required"] = "true"
end
