require 'spec_helper'

describe 'QuadPay Global setting' do
  context 'all info setting up in Spree::Config' do
    before do
      Spree::Config.quad_pay_site_url = 'quad_pay_site_url'
      Spree::Config.quad_pay_merchant_name = 'quad_pay_merchant_name'
      Spree::Config.quad_pay_client_id = 'quad_pay_client_id'
      Spree::Config.quad_pay_client_secret = 'quad_pay_client_secret'
      Spree::Config.quad_pay_min_amount = 'quad_pay_min_amount'
      Spree::Config.quad_pay_max_amount = 'quad_pay_max_amount'
      Spree::Config.quad_pay_display_widget_at_product_page = false
      Spree::Config.quad_pay_display_widget_at_cart_page = false
      Spree::Config.quad_pay_display_widget_at_checkout_process = false
      Spree::Config.quad_pay_test_mode = false
    end

    it 'correct' do
      expect(Spree::Config.quad_pay_site_url).to eq 'quad_pay_site_url'
      expect(Spree::Config.quad_pay_merchant_name).to eq 'quad_pay_merchant_name'
      expect(Spree::Config.quad_pay_client_id).to eq 'quad_pay_client_id'
      expect(Spree::Config.quad_pay_client_secret).to eq 'quad_pay_client_secret'
      expect(Spree::Config.quad_pay_min_amount).to eq 'quad_pay_min_amount'
      expect(Spree::Config.quad_pay_max_amount).to eq 'quad_pay_max_amount'
      expect(Spree::Config.quad_pay_display_widget_at_product_page).to eq false
      expect(Spree::Config.quad_pay_display_widget_at_cart_page).to eq false
      expect(Spree::Config.quad_pay_display_widget_at_checkout_process).to eq false
      expect(Spree::Config.quad_pay_test_mode).to eq false
    end
  end
end
