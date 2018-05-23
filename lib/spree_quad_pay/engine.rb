module SpreeQuadPay
  class Engine < Rails::Engine
    require 'spree/core'
    isolate_namespace Spree
    engine_name 'spree_quad_pay'

    initializer 'spree.gateway.payment_methods', after: 'spree.register.payment_methods' do |app|
      app.config.spree.payment_methods << Spree::BillingIntegration::QuadPayCheckout
    end

    initializer 'spree_quad_pay.helpers' do
      ActionView::Base.send :include, Spree::QuadPayHelper
    end

    initializer 'spree_quad_pay.configuration' do
      Spree::AppConfiguration.class_eval do
        preference :quad_pay_site_url, :string, default: 'https://your-website.com/'
        preference :quad_pay_merchant_name, :string
        preference :quad_pay_client_id, :string
        preference :quad_pay_client_secret, :string
        preference :quad_pay_min_amount, :float, default: 1
        preference :quad_pay_max_amount, :float, default: 1500
        preference :quad_pay_display_widget_at_product_page, :boolean, default: true
        preference :quad_pay_display_widget_at_cart_page, :boolean, default: true
        preference :quad_pay_test_mode, :boolean, default: true
      end
    end

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), '../../app/**/*_decorator*.rb')) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end

    config.to_prepare &method(:activate).to_proc
  end
end
