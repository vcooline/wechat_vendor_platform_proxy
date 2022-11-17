require 'test_helper'

module WechatVendorPlatformProxy::V3
  class ProfitSharingServiceTest < ActiveSupport::TestCase
    setup do
      @receiver = wechat_vendor_platform_proxy_profit_sharing_receivers(:one)
      @vendor = @receiver.vendor
    end

    test "should add receiver" do
      stub_request(:post, "https://api.mch.weixin.qq.com/v3/profitsharing/receivers/add")
        .to_return(status: 200, body: {account: "TEST_00000000000000000000001", relation_type: "USER", type: "PERSONAL_OPENID"}.to_json, headers: {})

      record = assert_difference "@vendor.profit_sharing_receivers.count", 1 do
        ProfitSharingService.new(@vendor).add_receiver \
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
      stub_request(:post, "https://api.mch.weixin.qq.com/v3/profitsharing/receivers/add")
        .to_return(status: 403, body: {code: "NO_AUTH"}.to_json, headers: {})

      assert_raises ProfitSharingService::NoAuth do
        ProfitSharingService.new(@vendor).add_receiver \
          app_id: "wx0000000000000001",
          type: "PERSONAL_OPENID",
          account: "TEST_00000000000000000000001",
          relation_type: "USER"
      end
    end

    test "should delete receiver" do
      stub_request(:post, "https://api.mch.weixin.qq.com/v3/profitsharing/receivers/delete")
        .to_return(status: 200, body: {account: @receiver.account, type: @receiver.account_type.upcase}.to_json, headers: {})

      record = assert_difference "@vendor.profit_sharing_receivers.count", -1 do
        ProfitSharingService.new(@vendor).delete_receiver \
          appid: @receiver.app_id,
          account: @receiver.account,
          type: @receiver.account_type.upcase
      end

      assert_equal @receiver.id, record.id
      assert record.destroyed?
    end

    test "raise InvalidRequest when delete receiver" do
      stub_request(:post, "https://api.mch.weixin.qq.com/v3/profitsharing/receivers/delete")
        .to_return(status: 400, body: {code: "INVALID_REQUEST"}.to_json, headers: {})

      assert_raises ProfitSharingService::InvalidRequest do
        ProfitSharingService.new(@vendor).delete_receiver \
          appid: @receiver.app_id,
          account: @receiver.account,
          type: @receiver.account_type.upcase
      end
    end

    test "should query transaction remain amount" do
      stub_request(:get, "https://api.mch.weixin.qq.com/v3/profitsharing/transactions/FILLER/amounts")
        .to_return(status: 200, body: {transaction_id: "FILLER", unsplit_amount: 1000}.to_json, headers: {})

      resp_info = ProfitSharingService.new(@vendor).query_remain_amount(transaction_id: "FILLER")
      assert resp_info["unsplit_amount"].present?
    end

    test "raise InvalidRequest when query remain amount" do
      stub_request(:get, "https://api.mch.weixin.qq.com/v3/profitsharing/transactions/FILLER/amounts")
        .to_return(status: 400, body: {code: "INVALID_REQUEST"}.to_json, headers: {})

      assert_raises ProfitSharingService::InvalidRequest do
        ProfitSharingService.new(@vendor).query_remain_amount(transaction_id: "FILLER")
      end
    end

    test "should unfreeze transaction remian amount" do
      stub_request(:post, "https://api.mch.weixin.qq.com/v3/profitsharing/orders/unfreeze")
        .to_return(status: 200, body: {
          "transaction_id": "4208450740201411110007820472",
          "out_order_no": "P20150806125346",
          "order_id": "3008450740201411110007820472",
          "state": "FINISHED",
          "receivers": [
            {
              "amount": 100,
              "description": "分给商户1900000110",
              "type": "MERCHANT_ID",
              "account": "1900000109",
              "detail_id": "36011111111111111111111",
              "result": "SUCCESS",
              "fail_reason": "ACCOUNT_ABNORMAL",
              "create_time": "2015-05-20T13:29:35+08:00",
              "finish_time": "2015-05-20T13:29:35+08:00"
            }
          ]
        }.to_json, headers: {})

      resp_info = ProfitSharingService.new(@vendor).unfreeze \
        transaction_id: "FILLER",
        out_order_no: "TEST_000000001",
        description: "FILLER"
      assert resp_info["out_order_no"].present?
      assert resp_info["order_id"].present?
      assert resp_info["state"].present?
    end

    test "raise NotEnough when unfreeze remain amount which is zero" do
      stub_request(:post, "https://api.mch.weixin.qq.com/v3/profitsharing/orders/unfreeze")
        .to_return(status: 403, body: {code: "NOT_ENOUGH"}.to_json, headers: {})

      assert_raises ProfitSharingService::NotEnough do
        ProfitSharingService.new(@vendor).unfreeze \
          transaction_id: "FILLER",
          out_order_no: "TEST_000000001",
          description: "FILLER"
      end
    end

    test "should apply profit sharing order" do
      stub_request(:post, "https://api.mch.weixin.qq.com/v3/profitsharing/orders")
        .to_return(status: 200, body: {
          "transaction_id": "4208450740201411110007820472",
          "out_order_no": "P20150806125346",
          "order_id": "3008450740201411110007820472",
          "state": "PROCESSING",
          "receivers": [
            {
              "amount": 100,
              "description": "分给商户1900000110",
              "type": "MERCHANT_ID",
              "account": "1900000109",
              "result": "SUCCESS",
              "fail_reason": "ACCOUNT_ABNORMAL",
              "detail_id": "36011111111111111111111",
              "create_time": "2015-05-20T13:29:35+08:00",
              "finish_time": "2015-05-20T13:29:35+08:00"
            }
          ]
        }.to_json, headers: {})

      resp_info = ProfitSharingService.new(@vendor).apply(
        appid: "wx0000000000000001",
        transaction_id: "0000000000000000000000000000",
        out_order_no: "PROFIT_SHARING_ORDER_0000001",
        unfreeze_unsplit: false,
        receivers: [
          {
            type: @receiver.account_type.upcase,
            account: @receiver.account,
            amount: 1,
            description: "FILLER"
          }
        ]
      )

      assert resp_info["order_id"].present?
      assert_equal "PROCESSING", resp_info["state"]
      assert_not_empty resp_info["receivers"]
    end

    test "raise NotEnough when apply profit sharing order" do
      stub_request(:post, "https://api.mch.weixin.qq.com/v3/profitsharing/orders")
        .to_return(status: 403, body: {code: "NOT_ENOUGH"}.to_json, headers: {})

      assert_raises ProfitSharingService::NotEnough do
        ProfitSharingService.new(@vendor).apply(
          appid: "wx0000000000000001",
          transaction_id: "0000000000000000000000000000",
          out_order_no: "PROFIT_SHARING_ORDER_0000001",
          unfreeze_unsplit: false,
          receivers: [ { type: @receiver.account_type.upcase, account: @receiver.account, amount: 1, description: "FILLER" } ]
        )
      end
    end

    test "should query profit sharing order result" do
      out_order_no = "FILLER"
      transaction_id = "FILLER"
      stub_request(:get, "https://api.mch.weixin.qq.com/v3/profitsharing/orders/#{out_order_no}?&transaction_id=#{transaction_id}")
        .to_return(status: 200, body: {
          "transaction_id": "4208450740201411110007820472",
          "out_order_no": "P20150806125346",
          "order_id": "3008450740201411110007820472",
          "state": "FINISHED",
          "receivers": [
            {
              "amount": 100,
              "description": "分给商户1900000110",
              "type": "MERCHANT_ID",
              "account": "1900000109",
              "result": "SUCCESS",
              "fail_reason": "ACCOUNT_ABNORMAL",
              "detail_id": "36011111111111111111111",
              "create_time": "2015-05-20T13:29:35+08:00",
              "finish_time": "2015-05-20T13:29:35+08:00"
            }
          ]

        }.to_json, headers: {})

      resp_info = ProfitSharingService.new(@vendor).query(out_order_no:, transaction_id:)
      assert resp_info["order_id"].present?
      assert resp_info["state"].present?
      assert_not_empty resp_info["receivers"]
    end

    test "raise ResourceNotExists when query profit sharing order result" do
      out_order_no = "FILLER"
      transaction_id = "FILLER"
      stub_request(:get, "https://api.mch.weixin.qq.com/v3/profitsharing/orders/#{out_order_no}?&transaction_id=#{transaction_id}")
        .to_return(status: 404, body: {code: "RESOURCE_NOT_EXISTS"}.to_json, headers: {})

      assert_raises ProfitSharingService::ResourceNotExists do
        ProfitSharingService.new(@vendor).query(out_order_no:, transaction_id:)
      end
    end
  end
end
