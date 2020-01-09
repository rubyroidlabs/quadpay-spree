require 'active_merchant/billing/quad_pay_api'

class Spree::BillingIntegration::QuadPayCheckout < Spree::BillingIntegration
  include ActionView::Helpers::NumberHelper

  def configuration
    @configuration ||= quadpay_api.send_request('get', 'configuration', {})
  end

  def create_order(order)
    resp = quadpay_api.send_request('post', 'order', build_order_params(order))
    return nil unless [200, 201].include?(resp.code)
    resp['body']
  end

  def find_order(token)
    quadpay_api.send_request('get', "order/#{token}", {})
  end

  def purchased
    ActiveMerchant::Billing::Response.new(true, {})
  end

  def authorize
    ActiveMerchant::Billing::Response.new(true, {})
  end

  def capture
    ActiveMerchant::Billing::Response.new(true, {})
  end

  def refund(money, response, options = {})
    @payment = Spree::Payment.find_by(response_code: response)
    @qp_order_id = @payment.quad_pay_orders.last.try(:qp_order_id) if @payment
    if @payment && @qp_order_id
      refund_id = "Refund-#{@payment.order.number}-#{@payment.number}-#{Time.current.strftime('%Y%m%d%H%M%S')}"
      resp =
        quadpay_api.send_request(
          'post',
          "order/#{@qp_order_id}/refund",
          options.reverse_merge({
            "requestId" => refund_id,
            "merchantRefundReference" => refund_id,
            "amount" => number_to_currency(money, unit: '')
          })
        )

      ab_rsp =
        ActiveMerchant::Billing::Response.new(
          resp.code == 200,
          { message: resp['body']['msg'] },
          authorization: refund_id
        )

      @payment.log_entries.create(details: ab_rsp.to_yaml)
      ab_rsp #return
    else
      messages = []
      messages << Spree.t(:quadpay_payment_not_found) unless @payment
      messages << Spree.t(:quadpay_order_not_found) unless @qp_order_id
      ActiveMerchant::Billing::Response.new(false, {}, { 'message' => messages.join(' ') })
    end
  end

  def credit(money, response, options = {})
    refund((money/100.0).to_f, response)
  end

  def void(response)
    ActiveMerchant::Billing::Response.new(true, {})
  end

  def cancel(response)
    @payment = Spree::Payment.find_by(response_code: response)
    refund(@payment.amount.to_f, response)
  end

  def source_required?
    false
  end

  def auto_capture?
    true
  end

  def build_order_params(order)
    billing_address = order.billing_address
    shipping_address = order.shipping_address

    {
      'description': "Order ##{order.number}",
      'amount': number_to_currency(order.total.to_f, unit: ''),
      'consumer': {
        'phoneNumber': billing_address.phone,
        'givenNames': billing_address.first_name,
        'surname': billing_address.last_name,
        'email': order.email
      },
      'billing': {
        'addressLine1': billing_address.address1,
        'addressLine2': billing_address.address2,
        'city': billing_address.city,
        'postcode': billing_address.zipcode,
        'state': billing_address.state_text
      },
      'shipping': {
        'addressLine1': shipping_address.address1,
        'addressLine2': shipping_address.address2,
        'city': shipping_address.city,
        'postcode': shipping_address.zipcode,
        'state': shipping_address.state_text
      },
      'items': line_item_as_json(order),
      'merchant': {
        'redirectConfirmUrl': "#{site_url}/orders/quadpay_confirm",
        'redirectCancelUrl': "#{site_url}/orders/quadpay_cancel"
      },
      'merchantReference': order.number,
      'taxAmount': number_to_currency(order.tax_total, unit: ''),
      'shippingAmount': number_to_currency(order.shipment_total, unit: '')
    }
  end

  def site_url
    site_url = Spree::Config.quad_pay_site_url
    3.times { site_url.gsub!(/^\/|\/$/, '') } # ensure never have the splash of the end of url
    site_url
  end

  def line_item_as_json(order)
    items =
      order.line_items.map do |line_item|
        {
          description: line_item.variant.descriptive_name,
          name: line_item.variant.product.name,
          sku: line_item.variant.sku,
          quantity: line_item.quantity,
          price: number_to_currency(line_item.price, unit: '')
        }
      end

    if order.promo_total.to_f != 0
      items << {
        description: 'Promotion',
        name: 'Promotion',
        quantity: '1', # Do we need to specify quantity for Promotion?
        price: number_to_currency(order.promo_total.to_f, unit: '')
      }
    end

    items
  end

  def actions
    %w{credit}
  end

  private
    def quadpay_api
      @quadpay_api ||=
        ActiveMerchant::Billing::QuadPayApi.new(
          Spree::Config.quad_pay_client_id,
          Spree::Config.quad_pay_client_secret,
          Spree::Config.quad_pay_test_mode
        )
    end
end
