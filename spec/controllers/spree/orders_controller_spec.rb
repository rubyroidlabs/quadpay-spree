require "spec_helper"

RSpec.describe Spree::OrdersController, type: :controller do
  context 'GET before_action load_quaypay_payment' do
    xit 'payment not found'

    context 'QP Order find by token' do
      content 'found' do
        xit 'not redirect'
      end

      content 'not found' do
        xit 'alert error and redirect to cart page'
      end
    end
  end

  context 'GET #quadpay_cancel' do
    xit 'cancel payment and redirect to cart page'
  end

  context 'GET #quadpay_confirm' do
    context 'QP Order Approved' do
      xit 'complete payment, order success and redirect to completed page'
      xit 'complete payment success, order fail and redirect to payment step page'
    end

    context 'QP Order not Approved' do
      xit 'alert message and check by cron job another time'
    end
  end

  context '#go_to_order_page' do
    xit 'go to cart page'
    xit 'go to order completed page'
  end
end
