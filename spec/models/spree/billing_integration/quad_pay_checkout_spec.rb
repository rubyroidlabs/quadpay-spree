require 'spec_helper'

# TODO: Cleanup after test done
# Success token
# 2b275847-0d1e-41da-9957-7a7aae0bcefe
# <OpenStruct code=200, body={"orderId"=>"ed1a8bb1-d56a-44c9-9c1a-e6f1af4fcd08", "orderStatus"=>"Approved", "amount"=>359.04, "consumer"=>nil, "billing"=>{"addressLine1"=>"4000 Main St.", "addressLine2"=>nil, "suburb"=>nil, "city"=>"Anytown", "postcode"=>"85001", "state"=>"AL"}, "shipping"=>{"addressLine1"=>"123 Test st.", "addressLine2"=>"1", "suburb"=>nil, "city"=>"Somewhere", "postcode"=>"90001", "state"=>"CA"}, "description"=>nil, "items"=>[{"description"=>nil, "name"=>"Ruby on Rails Tote", "sku"=>"ROR-00011", "quantity"=>1, "price"=>15.99}, {"description"=>nil, "name"=>"hiep", "sku"=>"H2", "quantity"=>3, "price"=>25.0}, {"description"=>nil, "name"=>"Promotion", "sku"=>nil, "quantity"=>1, "price"=>-35.69}, {"description"=>nil, "name"=>"Ruby on Rails Baseball Jersey", "sku"=>"ROR-00003", "quantity"=>2, "price"=>19.99}, {"description"=>nil, "name"=>"Spree Bag", "sku"=>"SPR-00012", "quantity"=>2, "price"=>22.99}, {"description"=>nil, "name"=>"Ruby on Rails Baseball Jersey", "sku"=>"ROR-00008", "quantity"=>4, "price"=>19.99}, {"description"=>nil, "name"=>"hiep", "sku"=>"h1", "quantity"=>2, "price"=>20.0}, {"description"=>nil, "name"=>"Ruby on Rails Ringer T-Shirt", "sku"=>"ROR-00015", "quantity"=>3, "price"=>19.99}], "merchant"=>{"redirectConfirmUrl"=>"https://tester-nspired-tech.ngrok.io/orders/quadpay_cancel", "redirectCancelUrl"=>"https://tester-nspired-tech.ngrok.io/orders/quadpay_cancel", "statusCallbackUrl"=>nil}, "merchantReference"=>"R508318305", "taxAmount"=>17.85, "shippingAmount"=>20.0, "token"=>"2b275847-0d1e-41da-9957-7a7aae0bcefe", "promotions"=>nil}>

# refund success
# <OpenStruct code=200, body={"id"=>"ea0bca6e-aaae-4570-a675-28767a538e86", "refundedDateTime"=>"2018-05-21T05:35:57.1806007Z", "merchantReference"=>"c6f32647-03b1-4206-818f-c2e2fe8ae7f8", "amount"=>30.44}>
# <OpenStruct code=200, body={"id"=>"c62a2814-f65b-4038-8349-11222ca0c0a9", "refundedDateTime"=>"2018-05-21T05:37:26.3933443Z", "merchantReference"=>"c6f3ccc2647-03b1-4206-818f-c2e2fe8ae7f8", "amount"=>30.44}>
# <OpenStruct code=200, body={"id"=>"4a14671c-b986-4b70-8fe9-e6ac2728f03c", "refundedDateTime"=>"2018-05-21T05:38:02.5511356Z", "merchantReference"=>"c6f3cc2647-03b1-4206-818f-c2e2fe8ae7f8x2", "amount"=>90.44}>
# refund error
# <OpenStruct code=422, body={'msg' => 'error message}>

# Cancel
# <OpenStruct code=200, body={"orderId"=>"ed1a8bb1-d56a-44c9-9c1a-e6f1af4fcd08", "orderStatus"=>"Created", "amount"=>359.04, "consumer"=>nil, "billing"=>{"addressLine1"=>"4000 Main St.", "addressLine2"=>nil, "suburb"=>nil, "city"=>"Anytown", "postcode"=>"85001", "state"=>"AL"}, "shipping"=>{"addressLine1"=>"123 Test st.", "addressLine2"=>"1", "suburb"=>nil, "city"=>"Somewhere", "postcode"=>"90001", "state"=>"CA"}, "description"=>nil, "items"=>[{"description"=>nil, "name"=>"Ruby on Rails Tote", "sku"=>"ROR-00011", "quantity"=>1, "price"=>15.99}, {"description"=>nil, "name"=>"hiep", "sku"=>"H2", "quantity"=>3, "price"=>25.0}, {"description"=>nil, "name"=>"Promotion", "sku"=>nil, "quantity"=>1, "price"=>-35.69}, {"description"=>nil, "name"=>"Ruby on Rails Baseball Jersey", "sku"=>"ROR-00003", "quantity"=>2, "price"=>19.99}, {"description"=>nil, "name"=>"Spree Bag", "sku"=>"SPR-00012", "quantity"=>2, "price"=>22.99}, {"description"=>nil, "name"=>"Ruby on Rails Baseball Jersey", "sku"=>"ROR-00008", "quantity"=>4, "price"=>19.99}, {"description"=>nil, "name"=>"hiep", "sku"=>"h1", "quantity"=>2, "price"=>20.0}, {"description"=>nil, "name"=>"Ruby on Rails Ringer T-Shirt", "sku"=>"ROR-00015", "quantity"=>3, "price"=>19.99}], "merchant"=>{"redirectConfirmUrl"=>"https://tester-nspired-tech.ngrok.io/orders/quadpay_cancel", "redirectCancelUrl"=>"https://tester-nspired-tech.ngrok.io/orders/quadpay_cancel", "statusCallbackUrl"=>nil}, "merchantReference"=>"R508318305", "taxAmount"=>17.85, "shippingAmount"=>20.0, "token"=>"2b275847-0d1e-41da-9957-7a7aae0bcefe", "promotions"=>nil}>


describe Spree::BillingIntegration::QuadPayCheckout, type: :model do
  include QuadPayApiStub

  before :all do
    @quad_pay_checkout =
      Spree::BillingIntegration::QuadPayCheckout.new(
        :name => 'QuadPayCheckout',
        :type => "Spree::BillingIntegration::QuadPayCheckout",
        :description => 'QuadPayCheckout',
        :active => true,
        :display_on => "both"
      )
  end

  it '#configuration' do
    qp_api = ActiveMerchant::Billing::QuadPayApi.new('client_id', 'client_secret', true)
    stub_send_request('GET', 'orders', 200, { abc: 'test' })
    qp_api.send_request('get', 'orders', {})
  end

  it '#create_order' do
  end

  it '#find_order' do
  end

  it '#purchased' do
  end

  it '#authorize' do
  end

  it '#capture' do
  end

  it '#refund' do
  end

  it '#credit' do
  end

  it '#void' do
  end

  it '#cancel' do
  end

  it '#source_required?' do
    expect(Spree::BillingIntegration::QuadPayCheckout.new.source_required?).to eq false
  end

  it '#auto_capture?' do
    expect(Spree::BillingIntegration::QuadPayCheckout.new.source_required?).to eq false
  end

  it '#build_order_params' do
  end

  it '#site_url' do
  end

  it '#line_item_as_json' do
  end

  it '#actions' do
  end

  it '#quadpay_api' do
  end
end

