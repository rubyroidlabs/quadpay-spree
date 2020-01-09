require 'spec_helper'

describe Spree::BillingIntegration::QuadPayCheckout, type: :model do
  include QuadPayApiStub
  include QuadPayResponse

  before :all do
    @qp_payment_method ||=
      Spree::BillingIntegration::QuadPayCheckout.create(
        name: 'QuadPayCheckout',
        type: 'Spree::BillingIntegration::QuadPayCheckout',
        description: 'QuadPayCheckout',
        active: true,
        display_on: 'both'
      )
  end

  before do
    stub_send_request('get', 'configuration', 200, configuration_response) # create_order
    stub_send_request('post', 'order', 200, create_order_response) # create_order
    stub_send_request('get', 'order?token=qp_token', 200, find_order_response) # find_order
    stub_send_request('post', 'order/qp_order_id/refund', 200, refund_response(20)) # refund
  end

  it '#configuration' do
    resp = @qp_payment_method.configuration
    expect(resp.code).to eq 200
    expect(resp.body['minimumAmount']).to eq 50
    expect(resp.body['maximumAmount']).to eq 950
  end

  it '#create_order' do
    order = create(:order_with_line_items)
    resp = @qp_payment_method.create_order(order)
    expect(resp['token']).to eq 'qp_token'
    expect(resp['orderId']).to eq 'qp_order_id'
    expect(resp['redirectUrl']).to eq 'https://checkout-ut.quadpay.com/checkout?token=qp_token'
  end

  it '#find_order' do
    resp = @qp_payment_method.find_order('qp_token')
    expect(resp.code).to eq 200
    expect(resp.body['orderId']).to eq 'qp_order_id'
    expect(resp.body['orderStatus']).to eq 'Created'
  end

  it '#purchased' do
    resp = @qp_payment_method.purchased
    expect(resp.success?).to eq true
  end

  it '#authorize' do
    resp = @qp_payment_method.authorize
    expect(resp.success?).to eq true
  end

  it '#capture' do
    resp = @qp_payment_method.capture
    expect(resp.success?).to eq true
  end

  context '#refund' do
    before do
      @order = create(:shipped_order)
      @order.payments.each(&:cancel!)
      @payment = @order.payments.create(
        payment_method: @qp_payment_method,
        response_code: 'qp_token'
      )
      @payment.complete!
      @payment.quad_pay_orders.create(
        qp_order_id: 'qp_order_id',
        qp_order_token: 'qp_token'
      )
    end

    it 'payment not found' do
      resp = @qp_payment_method.refund(20, 'qp_token_fake')
      expect(resp.params['message']).to include 'QuadPay payment not found.'
    end

    it 'success' do
      resp = @qp_payment_method.refund(20, 'qp_token')
      expect(resp.success?).to eq true
    end
  end

  it '#credit' do
    # It's just call method refund
  end

  it '#cancel' do
    # It's just call method refund
  end

  it '#void' do
    resp = @qp_payment_method.void('qp_token')
    expect(resp.success?).to eq true
  end

  it '#source_required? always false' do
    expect(@qp_payment_method.source_required?).to eq false
  end

  it '#auto_capture? always true' do
    expect(@qp_payment_method.auto_capture?).to eq true
  end

  context '#site_url' do
    it 'have 1 splash' do
      Spree::Config.quad_pay_site_url = 'http://abc.com/'
      expect(@qp_payment_method.site_url).to eq 'http://abc.com'
    end

    it 'have 2 splash' do
      Spree::Config.quad_pay_site_url = 'http://abc.com//'
      expect(@qp_payment_method.site_url).to eq 'http://abc.com'
    end

    it 'have 3 splash' do
      Spree::Config.quad_pay_site_url = 'http://abc.com///'
      expect(@qp_payment_method.site_url).to eq 'http://abc.com'
    end
  end

  it '#build_order_params' do
    order = create(:order_with_line_items)
    resp = @qp_payment_method.build_order_params(order)
    billing_address = order.billing_address
    shipping_address = order.shipping_address
    line_item = order.line_items.first

    expect(resp[:amount].to_f).to eq order.total.to_f
    expect(resp[:consumer][:phoneNumber]).to eq billing_address.phone
    expect(resp[:consumer][:givenNames]).to eq billing_address.first_name
    expect(resp[:consumer][:surname]).to eq billing_address.last_name
    expect(resp[:consumer][:email]).to eq order.email

    expect(resp[:billing][:addressLine1]).to eq billing_address.address1
    expect(resp[:billing][:addressLine2]).to eq billing_address.address2
    expect(resp[:billing][:city]).to eq billing_address.city
    expect(resp[:billing][:postcode]).to eq billing_address.zipcode
    expect(resp[:billing][:state]).to eq billing_address.state_text

    expect(resp[:shipping][:addressLine1]).to eq shipping_address.address1
    expect(resp[:shipping][:addressLine2]).to eq shipping_address.address2
    expect(resp[:shipping][:city]).to eq shipping_address.city
    expect(resp[:shipping][:postcode]).to eq shipping_address.zipcode
    expect(resp[:shipping][:state]).to eq shipping_address.state_text

    expect(resp[:items].length).to eq 1
    expect(resp[:items][0][:description]).to eq line_item.variant.descriptive_name
    expect(resp[:items][0][:name]).to eq line_item.variant.product.name
    expect(resp[:items][0][:sku]).to eq line_item.variant.sku
    expect(resp[:items][0][:quantity]).to eq line_item.quantity
    expect(resp[:items][0][:price].to_f).to eq line_item.price.to_f

    expect(resp[:merchant][:redirectConfirmUrl]).to include Spree::Config.quad_pay_site_url
    expect(resp[:merchant][:redirectCancelUrl]).to include Spree::Config.quad_pay_site_url
    expect(resp[:merchantReference]).to eq order.number
    expect(resp[:taxAmount].to_f).to eq order.tax_total.to_f
    expect(resp[:shippingAmount].to_f).to eq order.shipment_total.to_f
  end

  it '#line_item_as_json' do
    # It's just call from build_order_params
  end
end
