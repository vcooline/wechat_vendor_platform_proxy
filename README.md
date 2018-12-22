# WechatVendorPlatformProxy
微信商户平台（微信支付）代理Engine

## Usage

* 商户平台

    Mount engine in host rails routes: mount WechatVendorPlatformProxy::Engine, at: "/wxpay"

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'wechat_vendor_platform_proxy', git: "git@github.com:vcooline/wechat_vendor_platform_proxy.git", branch: "master"
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install wechat_vendor_platform_proxy
```

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
