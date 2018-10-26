require "spec_helper"
require 'rspec/active_model/mocks'

RSpec.describe Spree::CheckoutController, type: :controller do
  include QuadPayApiStub
  include QuadPayResponse

  let(:token) { 'some_token' }
  let(:user) { stub_model(Spree::LegacyUser) }
  let(:order) { OrderWalkthrough.up_to(:payment) }

  before do
    allow(controller).to receive_messages try_spree_current_user: user
    allow(controller).to receive_messages spree_current_user: user
    allow(controller).to receive_messages current_order: order

    @qp_payment_method ||=
      Spree::BillingIntegration::QuadPayCheckout.create(
        name: 'QuadPayCheckout',
        type: 'Spree::BillingIntegration::QuadPayCheckout',
        description: 'QuadPayCheckout',
        active: true,
        display_on: 'both'
      )

    @quad_pay_payment_params ||= {
      state: 'payment',
      order: {
        payments_attributes: [{
          payment_method_id: @qp_payment_method.id
        }]
      }}
  end

  context 'Process QuadPay payment method' do
    before do
      expect(order.state).to eq 'payment'
      allow(order).to receive_messages user: user
      allow(order).to receive_messages confirmation_required?: true
      stub_send_request('post', 'order', 200, create_order_response)
      Spree::Order
        .any_instance
        .stub(:available_payment_methods)
        .and_return(Spree::PaymentMethod.available_on_front_end)
    end

    context 'not processing' do
      it 'when payment method selected is not QuadPay' do
        payment_method = FactoryBot.create(:simple_credit_card_payment_method)
        spree_put :update, state: 'payment',
          order: {
            payments_attributes: [{
              payment_method_id: payment_method.id
            }]
          }

        order.reload
        expect(order.state).to eq 'confirm'
      end
    end

    context 'Process' do
      context 'found' do
        it 'save Order ID and token' do
          spree_put :update, @quad_pay_payment_params
          quad_pay_order = order.payments.last.quad_pay_orders.first
          expect(quad_pay_order.qp_order_token).to eq 'qp_token'
          expect(quad_pay_order.qp_order_id).to eq 'qp_order_id'
        end

        it 'redirect to QuadPay Site' do
          spree_put :update, @quad_pay_payment_params
          expect(response).to redirect_to 'https://checkout-ci.quadpay.com/checkout?token=qp_token'
        end
      end

      context 'not found' do
        it 'alert error and redirect to cart page' do
          stub_send_request('post', 'order', 200, nil)
          spree_put :update, @quad_pay_payment_params
          expect(response).to redirect_to checkout_state_path('payment')
          expect(response.request.env['action_dispatch.request.flash_hash']['error']).to eq Spree.t(:quad_pay_checkout_error)
        end
      end
    end
  end
end
