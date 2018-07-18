module Spree
  module QuadPayHelper
    QUADPAY_WIDGET_URL_BASE = "https://widgets.quadpay.com"

    def quadpay_active_on_front_end?
      Spree::BillingIntegration::QuadPayCheckout.available_on_front_end.exists?(active: true)
    end

    def display_quadpay_widget_on_product_page?
      return false unless quadpay_active_on_front_end?

      Spree::Config.quad_pay_display_widget_at_product_page
    end

    def display_quadpay_widget_on_cart_page?
      return false unless current_order
      return false unless quadpay_active_on_front_end?

      Spree::Config.quad_pay_display_widget_at_cart_page
    end

    def display_quadpay_widget_on_checkout_page?
      return false unless current_order
      return false unless quadpay_active_on_front_end?

      Spree::Config.quad_pay_display_widget_at_checkout_process
    end

    def quadpay_product_widget(product_price)
      return '' unless product_price

      order_total = current_order ? current_order.total.to_f : 0

      quadpay_widget(
        amount: product_price,
        future_order_total: order_total + product_price
      )
    end

    def quadpay_cart_widget
      return '' unless current_order

      quadpay_widget(
        amount: current_order.total,
        future_order_total: current_order.total
      )
    end

    def quadpay_widget(amount:, future_order_total:)
      min_amount = Spree::Config.quad_pay_min_amount.to_f
      max_amount = Spree::Config.quad_pay_max_amount.to_f

      installment_amount = (amount / 4.0 * 100).to_i / 100.0
      widget_url = quadpay_widget_url(min: min_amount, max: max_amount, amount: amount)

      body = if future_order_total > max_amount
          "on orders below #{number_to_currency(max_amount)}"
        elsif future_order_total < min_amount
          "on orders above #{number_to_currency(min_amount)}"
        else
          "of <span style='font-weight: bold;'>#{number_to_currency(installment_amount)}</span>"
        end

      widget_html = <<-HTML
        <!-- QuadPay Product Page Widget START -->
        <div id='quadPayCalculatorWidget'>
          <p id='quadPayCalculatorWidgetText'>
            or 4 Interest-Free Payments
            #{body}
            with
            <img id='quadPayCalculatorWidgetLogo' src='https://assets.quadpay.com/assets/images/quadpay-logo-actually-black-tight-200.png' style='width: 90px;'>
          </div>
          <div id="quadPayCalculatorWidgetLearn" style="font-size: smaller; text-align: right; cursor: pointer; margin-top: -4px; margin-right: 2px;">
            <script async src='#{widget_url}' type='application/javascript'></script>
          </div>
        </div>
        <!-- QuadPay Product Page Widget END -->
      HTML

      widget_html.html_safe
    end

    def quadpay_widget_url(min:, max:, amount:)
      "#{QUADPAY_WIDGET_URL_BASE}#{Spree::Config.quad_pay_merchant_name}/quadpay-widget-0.2.0.js?type=calculator&min=#{min}&max=#{max}&amount=#{amount}"
    end
  end
end
