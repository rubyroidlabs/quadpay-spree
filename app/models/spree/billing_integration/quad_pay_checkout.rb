require 'active_merchant/billing/quad_pay_api'

class Spree::BillingIntegration::QuadPayCheckout < Spree::BillingIntegration
  include ActionView::Helpers::NumberHelper

  preference :site_url, :string, default: 'https://your-website.com/'
  preference :merchant_name, :string
  preference :client_id, :string
  preference :client_secret, :string

  def create_order(order)
    quadpay_api.send_request('post', 'order', build_order_params(order))
  end
  
  def find_order(token)
    quadpay_api.send_request('get', 'order', token)
  end

  def purchased
  end

  def authorize
  end

  def capture
  end

  def void
  end

  def source_required?
    false
  end

  def auto_capture?
    true
  end

  def redirect_url(order)
    resp = create_order(order)
    return nil unless [200, 201].include?(resp.code)
    resp['body']['redirectUrl']
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
        'redirectConfirmUrl': "#{site_url}/#{order.number}/quadpay_cancel",
        'redirectCancelUrl': "#{site_url}/#{order.number}/quadpay_confirm"
      },
      'merchantReference': order.number,
      'taxAmount': number_to_currency(order.tax_total, unit: ''),
      'shippingAmount': number_to_currency(order.shipment_total, unit: '')
    }
  end

  def site_url
    site_url = preferences[:site_url]
    3.times { site_url.gsub!(/^\/|\/$/, '') }
    site_url
  end

  def line_item_as_json(order)
    items =
      order.line_items.map do |line_item|
        {
          description: "#{line_item.variant.descriptive_name}",
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

  private
    def quadpay_api
      @quadpay_api ||=
        ActiveMerchant::Billing::QuadPayApi.new(
          preferences[:client_id],
          preferences[:client_secret],
          preferences[:test_mode]
        )
    end
end


