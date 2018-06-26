module Spree
  module QuadPayHelper
    def quad_pay_widget(type, amount)
      min_amount = Spree::Config.quad_pay_min_amount.to_f
      max_amount = Spree::Config.quad_pay_max_amount.to_f
      order_total = current_order.total.to_f rescue 0

      # Logic show/hide widget
      # Cart page the logic should be: "IF (cart.total_price > min_order_total)
      #   THEN show_widget"
      # Product page the logic should be: "IF (product.price > min_order_total)
      #   OR (cart.total_price > min_order_total) THEN show_widget"
      condition_on_cart = min_amount < order_total && order_total < max_amount
      condition_on_amount = min_amount < amount && amount < max_amount
      return if %w(cart checkout).include?(type) && !condition_on_cart
      return if type == 'product' && !condition_on_amount && !condition_on_cart

      if qpm = Spree::BillingIntegration::QuadPayCheckout.available_on_front_end.active.first
        display_widget =
          case type
            when 'product'
              Spree::Config.quad_pay_display_widget_at_product_page
            when 'cart'
              Spree::Config.quad_pay_display_widget_at_cart_page
            when 'checkout'
              Spree::Config.quad_pay_display_widget_at_checkout_process
            end
        if display_widget
          payment_amount = (amount / 4.0 * 100).to_i / 100.0
          url = "https://widgets.quadpay.com/#{Spree::Config.quad_pay_merchant_name}/quadpay-widget-0.1.0.js?type=calculator&min=#{min_amount}&max=#{max_amount}&amount=#{payment_amount}"
          widget_html(number_to_currency(payment_amount), url).html_safe
        end
      end
    end

    def widget_html(amount, widget_url)
      <<-HTML
        <!-- QuadPay Product Page Widget START -->
        <div id='quadPayCalculatorWidget' class='yui3-cssreset' style='min-height: 40px; padding: 7px 0; width: 100%; max-width: 350px; color: black; text-transform: none; box-sizing: inherit;'>
          <img id='quadPayCalculatorWidgetLogo' src='https://assets.quadpay.com/assets/images/quadpay-logo-actually-black-tight-200.png' style='width: 90px; float: right;'>
          <div id='quadPayCalculatorWidgetText' style='position: relative; text-align: left;'>or 4 Interest-Free Payments
            <span id='quadPayCalculatorWidgetTextFromCopy' sytle='margin-right: 10px;'>of <span style='font-weight: bold;'>#{amount}</span></span>
          </div>
          <script async src='#{widget_url}' type='application/javascript'></script>
        </div>
        <!-- QuadPay Product Page Widget END -->
      HTML
    end
  end
end
