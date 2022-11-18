require 'test_helper'

module WechatVendorPlatformProxy::ECommerce
  class ProfitSharingServiceTest < ActiveSupport::TestCase
    setup do
      @receiver = wechat_vendor_platform_proxy_profit_sharing_receivers(:two)
      @sp_vendor = wechat_vendor_platform_proxy_vendors(:sp_two)
      @ec_vendor = wechat_vendor_platform_proxy_vendors(:ec_two)
    end

    test "should add receiver" do
      stub_request(:post, "https://api.mch.weixin.qq.com/v3/ecommerce/profitsharing/receivers/add")
        .to_return(status: 200, body: {account: "TEST_00000000000000000000001", type: "PERSONAL_OPENID"}.to_json, headers: {})

      record = assert_difference "@sp_vendor.profit_sharing_receivers.count", 1 do
        ProfitSharingService.new(@sp_vendor).add_receiver \
          appid: "wx0000000000000001",
          type: "PERSONAL_OPENID",
          account: "TEST_00000000000000000000001",
          relation_type: "USER"
      end

      assert record.persisted?
      assert record.personal_openid?
      assert record.user?
      assert_equal "wx0000000000000001", record.app_id
      assert_equal "TEST_00000000000000000000001", record.account
    end

    test "raise NoAuth when add receiver" do
      stub_request(:post, "https://api.mch.weixin.qq.com/v3/ecommerce/profitsharing/receivers/add")
        .to_return(status: 403, body: {code: "NO_AUTH"}.to_json, headers: {})

      assert_raises ProfitSharingService::NoAuth do
        ProfitSharingService.new(@sp_vendor).add_receiver \
          app_id: "wx0000000000000001",
          type: "PERSONAL_OPENID",
          account: "TEST_00000000000000000000001",
          relation_type: "USER"
      end
    end

    test "should delete receiver" do
      stub_request(:post, "https://api.mch.weixin.qq.com/v3/ecommerce/profitsharing/receivers/delete")
        .to_return(status: 200, body: {account: @receiver.account, type: @receiver.account_type.upcase}.to_json, headers: {})

      record = assert_difference "@sp_vendor.profit_sharing_receivers.count", -1 do
        ProfitSharingService.new(@sp_vendor).delete_receiver \
          appid: @receiver.app_id,
          account: @receiver.account,
          type: @receiver.account_type.upcase
      end

      assert_equal @receiver.id, record.id
      assert record.destroyed?
    end

    test "raise InvalidRequest when delete receiver" do
      stub_request(:post, "https://api.mch.weixin.qq.com/v3/ecommerce/profitsharing/receivers/delete")
        .to_return(status: 400, body: {code: "INVALID_REQUEST"}.to_json, headers: {})

      assert_raises ProfitSharingService::InvalidRequest do
        ProfitSharingService.new(@sp_vendor).delete_receiver \
          appid: @receiver.app_id,
          account: @receiver.account,
          type: @receiver.account_type.upcase
      end
    end

    test "should query transaction remain amount" do
      stub_request(:get, "https://api.mch.weixin.qq.com/v3/ecommerce/profitsharing/orders/FILLER/amounts")
        .to_return(status: 200, body: {transaction_id: "FILLER", unsplit_amount: 1000}.to_json, headers: {})

      resp_info = ProfitSharingService.new(@sp_vendor).query_remain_amount(transaction_id: "FILLER")
      assert resp_info["unsplit_amount"].present?
    end

    test "raise InvalidRequest when query remain amount" do
      stub_request(:get, "https://api.mch.weixin.qq.com/v3/ecommerce/profitsharing/orders/FILLER/amounts")
        .to_return(status: 400, body: {code: "INVALID_REQUEST"}.to_json, headers: {})

      assert_raises ProfitSharingService::InvalidRequest do
        ProfitSharingService.new(@sp_vendor).query_remain_amount(transaction_id: "FILLER")
      end
    end

    test "should unfreeze transaction remian amount" do
      stub_request(:post, "https://api.mch.weixin.qq.com/v3/ecommerce/profitsharing/finish-order")
        .to_return(status: 200, body: {
          "sub_mchid": @ec_vendor.mch_id,
          "transaction_id": "4208450740201411110007820472",
          "out_order_no": "P20150806125346",
          "order_id": "3008450740201411110007820472"
        }.to_json, headers: {})

      resp_info = ProfitSharingService.new(@sp_vendor).unfreeze \
        sub_mchid: @ec_vendor.mch_id,
        transaction_id: "FILLER",
        out_order_no: "TEST_000000001",
        description: "FILLER"
      assert resp_info["out_order_no"].present?
      assert resp_info["order_id"].present?
    end

    test "raise NotEnough when unfreeze remain amount which is zero" do
      stub_request(:post, "https://api.mch.weixin.qq.com/v3/ecommerce/profitsharing/finish-order")
        .to_return(status: 403, body: {code: "NOT_ENOUGH"}.to_json, headers: {})

      assert_raises ProfitSharingService::NotEnough do
        ProfitSharingService.new(@sp_vendor).unfreeze \
          sub_mchid: @ec_vendor.mch_id,
          transaction_id: "FILLER",
          out_order_no: "TEST_000000001",
          description: "FILLER"
      end
    end

    test "should apply profit sharing order" do
      stub_request(:post, "https://api.mch.weixin.qq.com/v3/ecommerce/profitsharing/orders")
        .to_return(status: 200, body: {
          "sub_mchid": "1900000109",
          "transaction_id": "4208450740201411110007820472",
          "out_order_no": "P20150806125346",
          "order_id": "3008450740201411110007820472",
          "receivers": [
            {
              "amount": 100,
              "description": "分给商户1900000110",
              "detail_id": "36011111111111111111111",
              "fail_reason": "ACCOUNT_ABNORMAL",
              "finish_time": "2015-05-20T13:29:35.120+08:00",
              "receiver_account": "1900000109",
              "receiver_mchid": "1900000110",
              "result": "SUCCESS",
              "type": "MERCHANT_ID"
            }
          ],
          "status": "PROCESSING"
        }.to_json, headers: {})

      resp_info = ProfitSharingService.new(@sp_vendor).apply(
        appid: "wx0000000000000001",
        sub_mchid: @ec_vendor.mch_id,
        transaction_id: "0000000000000000000000000000",
        out_order_no: "PROFIT_SHARING_ORDER_0000002",
        finishe: false,
        receivers: [
          {
            type: @receiver.account_type.upcase,
            receiver_account: @receiver.account,
            amount: 1,
            description: "FILLER"
          }
        ]
      )

      assert resp_info["order_id"].present?
      assert_equal "PROCESSING", resp_info["status"]
      assert_not_empty resp_info["receivers"]
    end

    test "raise NotEnough when apply profit sharing order" do
      stub_request(:post, "https://api.mch.weixin.qq.com/v3/ecommerce/profitsharing/orders")
        .to_return(status: 403, body: {code: "NOT_ENOUGH"}.to_json, headers: {})

      assert_raises ProfitSharingService::NotEnough do
        ProfitSharingService.new(@sp_vendor).apply(
          appid: "wx0000000000000001",
          sub_mchid: @ec_vendor.mch_id,
          transaction_id: "0000000000000000000000000000",
          out_order_no: "PROFIT_SHARING_ORDER_0000001",
          finish: false,
          receivers: [ { type: @receiver.account_type.upcase, receiver_account: @receiver.account, amount: 1, description: "FILLER" } ]
        )
      end
    end

    test "should query profit sharing order result" do
      sub_mchid = "FILLER"
      out_order_no = "FILLER"
      transaction_id = "FILLER"
      stub_request(:get, "https://api.mch.weixin.qq.com/v3/ecommerce/profitsharing/orders?#{{sub_mchid:, transaction_id:, out_order_no:}.to_query}")
        .to_return(status: 200, body: {
          "sub_mchid": "1900000109",
          "transaction_id": "4208450740201411110007820472",
          "out_order_no": "P20150806125346",
          "order_id": "3008450740201411110007820472",
          "status": "FINISHED",
          "receivers": [
            {
              "receiver_mchid": "1900000110",
              "amount": 100,
              "description": "分给商户1900000110",
              "result": "SUCCESS",
              "detail_id": "36011111111111111111111",
              "finish_time": "2015-05-20T13:29:35.120+08:00",
              "fail_reason": "ACCOUNT_ABNORMAL"
            }
          ],
          "finish_amount": 100,
          "finish_description": "分账完结"
        }.to_json, headers: {})

      resp_info = ProfitSharingService.new(@sp_vendor).query(sub_mchid:, out_order_no:, transaction_id:)
      assert resp_info["order_id"].present?
      assert resp_info["status"].present?
      assert_not_empty resp_info["receivers"]
    end

    test "raise ResourceNotExists when query profit sharing order result" do
      sub_mchid = "FILLER"
      out_order_no = "FILLER"
      transaction_id = "FILLER"
      stub_request(:get, "https://api.mch.weixin.qq.com/v3/ecommerce/profitsharing/orders?#{{sub_mchid:, transaction_id:, out_order_no:}.to_query}")
        .to_return(status: 404, body: {code: "RESOURCE_NOT_EXISTS"}.to_json, headers: {})

      assert_raises ProfitSharingService::ResourceNotExists do
        ProfitSharingService.new(@sp_vendor).query(sub_mchid:, out_order_no:, transaction_id:)
      end
    end
  end
end
