# WechatVendorPlatformProxy
微信商户平台（微信支付）代理Engine

## Usage

* 商户平台

    Mount engine in host rails routes: mount WechatVendorPlatformProxy::Engine, at: "/wxpay"

## Definations

* marketing 营销工具

    * cash_coupon 代金券
    * business_coupon 商家券

* business_circle 商圈

* gold_plan 点金计划

* e_commerce 电商收付通

* profit_sharing 分账

* brand_profit_sharing 品牌分账

* risk 违规管理

* merchant_service 消费者投诉

* smart_guide 支付即服务

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
