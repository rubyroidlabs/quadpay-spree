require 'webmock/rspec'

module QuadPayApiStub
  def default_setting
    Spree::Config.quad_pay_site_url = 'quad_pay_site_url'
    Spree::Config.quad_pay_merchant_name = 'quad_pay_merchant_name'
    Spree::Config.quad_pay_client_id = 'quad_pay_client_id'
    Spree::Config.quad_pay_client_secret = 'quad_pay_client_secret'
    Spree::Config.quad_pay_min_amount = 'quad_pay_min_amount'
    Spree::Config.quad_pay_max_amount = 'quad_pay_max_amount'
    Spree::Config.quad_pay_display_widget_at_product_page = true
    Spree::Config.quad_pay_display_widget_at_cart_page = true
    Spree::Config.quad_pay_test_mode = true
  end

  def create_payment(qp_order_status, payment_status = 'checkout', order = nil)
    stub_send_request('post', 'order', 200, create_order_response)
    stub_send_request('get', 'order?token=qp_token', 200, find_order_response(qp_order_status))
    order ||= create(:order_with_line_items)
    create(
      :payment,
      order: order,
      response_code: 'qp_token',
      state: payment_status,
      payment_method: @qp_payment_method,
      source: nil
    )
  end

  def stub_send_request(type = 'get', path = '', status = 200, body = {})
    stub_access_token
    full_url = "https://api-ci.quadpay.com/#{path}"
    response = {
      status: status,
      body: body.to_json
    }

    stub_request(type.downcase.to_sym, full_url)
      .with(
        headers: {
          'Accept': '*/*',
          'Accept-Encoding': 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Authorization': 'Bearer qp_token',
          'Content-Type': 'application/json',
          'Host': 'api-ci.quadpay.com',
          'User-Agent': 'Ruby'
        }
      ).to_return(response)
  end

  def stub_access_token
    default_setting
    stub_request(:post, 'https://quadpay-dev.auth0.com/oauth/token')
      .to_return({
        status: 200,
        body: {
          access_token: 'qp_token'
        }.to_json
      })
  end
end
