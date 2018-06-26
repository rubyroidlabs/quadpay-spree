module Spree
  module Admin
    class QuadPaySettingsController < Spree::Admin::BaseController
      include Spree::Backend::Callbacks

      def edit
        @preferences_security = [
          :quad_pay_site_url,
          :quad_pay_merchant_name,
          :quad_pay_client_id,
          :quad_pay_client_secret,
          :quad_pay_min_amount,
          :quad_pay_max_amount,
          :quad_pay_display_widget_at_product_page,
          :quad_pay_display_widget_at_cart_page,
          :quad_pay_display_widget_at_checkout_process,
          :quad_pay_test_mode
        ]
      end

      def update
        params.each do |name, value|
          next unless Spree::Config.has_preference? name
          Spree::Config[name] = value
        end

        flash[:success] = Spree.t(:successfully_updated, resource: Spree.t(:quad_pay_settings))
        redirect_to edit_admin_quad_pay_settings_path
      end
    end
  end
end
