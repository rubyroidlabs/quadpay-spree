module Spree
  module QuadPayHelper
    def quad_pay_widget(type, amount)
      if qpm = Spree::BillingIntegration::QuadPayCheckout.available_on_front_end.active.first
        display_widget =
          case type
            when 'product'
              Spree::Config.quad_pay_display_widget_at_product_page
            when 'cart'
              Spree::Config.quad_pay_display_widget_at_cart_page
            end

        if display_widget
          url = "https://widgets.quadpay.com/#{Spree::Config.quad_pay_merchant_name}/quadpay-widget-0.1.0.js?type=calculator&min=#{Spree::Config.quad_pay_min_amount}&max=#{Spree::Config.quad_pay_max_amount}&amount=#{amount.to_f}"
          widget_html(amount, url).html_safe
        end
      end
    end

    def widget_html(amount, widget_url)
      <<-HTML
        <!-- QuadPay Product Page Widget START -->
        <div id='quadPayCalculatorWidget' class='yui3-cssreset' style='padding: 7px 0; width: 100%; max-width: 350px; color: black; text-transform: none; box-sizing: inherit;'>
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