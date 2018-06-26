require "spec_helper"

RSpec.describe Spree::OrdersController, type: :controller do
  include QuadPayApiStub
  include QuadPayResponse

  before :all do
    @qp_payment_method ||=
      Spree::BillingIntegration::QuadPayCheckout.create(
        name: 'QuadPayCheckout',
        type: 'Spree::BillingIntegration::QuadPayCheckout',
        description: 'QuadPayCheckout',
        active: true,
        display_on: 'both'
      )
  end

  context 'GET before_action load_quaypay_payment' do
    it 'payment not found' do
      create_payment('Approved', 'checkout')
      get :quadpay_confirm, params: { token: 'rake_qp_token' }
      expect(response.code).to eq "302"
      expect(flashes['notice']).to eq Spree.t(:quadpay_payment_invalid)
    end

    context 'QP Order find by token' do
      context 'found' do
        it 'not redirect' do
          payment = create_payment('Approved', 'checkout')
          get :quadpay_confirm, params: { token: 'qp_token' }
          payment.reload
          expect(response.code).to eq "302"
          expect(flashes['order_completed']).to eq true
          expect(payment.completed?).to eq true
          expect(payment.order.completed?).to eq true
        end
      end
    end
  end

  context 'GET #quadpay_cancel' do
    it 'cancel payment and redirect to cart page' do
      payment = create_payment('Created', 'checkout')
      get :quadpay_cancel, params: { token: 'qp_token' }
      payment.reload
      expect(response.code).to eq "302"
      expect(payment.completed?).to eq false
      expect(payment.order.completed?).to eq false
    end
  end

  context 'GET #quadpay_confirm' do
    context 'QP Order Approved' do
      it 'complete payment, order success and redirect to completed page' do
        payment = create_payment('Approved', 'checkout')
        get :quadpay_confirm, params: { token: 'qp_token' }
        payment.reload
        expect(response.code).to eq "302"
        expect(flashes['order_completed']).to eq true
        expect(payment.completed?).to eq true
        expect(payment.order.completed?).to eq true
      end

      it 'complete payment success, order fail and redirect to payment step page' do
        payment = create_payment('Approved', 'checkout', create(:order))
        get :quadpay_confirm, params: { token: 'qp_token' }
        payment.reload
        expect(response.code).to eq "302"
        expect(payment.completed?).to eq true
        expect(payment.order.completed?).to eq false
        expect(flashes['error']).to eq Spree.t(:quadpay_payment_fail, number: payment.order.number)
      end
    end

    context 'QP Order not Approved' do
      it 'alert message and check by cron job another time' do
        payment = create_payment('Created', 'checkout')
        get :quadpay_confirm, params: { token: 'qp_token' }
        payment.reload
        expect(response.code).to eq "302"
        expect(payment.completed?).to eq false
        expect(payment.order.completed?).to eq false
        expect(flashes['error']).to eq Spree.t(:quadpay_payment_fail, number: payment.order.number)
      end
    end
  end

  def flashes
    response.request.env['action_dispatch.request.flash_hash']
  end
end
