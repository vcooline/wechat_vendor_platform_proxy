$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "wechat_vendor_platform_proxy/version"

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

  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://gems.io-note.cn"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", ">= 6.1"
  spec.add_dependency "kaminari"
  spec.add_dependency "ransack"
  spec.add_dependency "jbuilder"
  spec.add_dependency "faraday"
  spec.add_dependency "faraday-multipart"

  spec.add_development_dependency "sqlite3"
end
