require 'spec_helper'
require 'rake'

describe :quad_pay_tasks do
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

    Rake.application.rake_require 'tasks/quad_pay_tasks'
    Rake::Task.define_task(:environment)
  end

  context 'quad_pay_payments' do
    context 'invalid quadpay payment' do
      it 'created at > 15 mins' do
        payment = create_payment('Approved')
        payment.update(created_at: 20.minutes.ago)
        run_rake_task
        payment.reload
        expect(payment.completed?).to eq false

        payment.update(created_at: 10.minutes.ago)
        run_rake_task
        payment.reload
        expect(payment.completed?).to eq true
      end

      it 'payment method is not quadpay' do
        stub_send_request('post', 'order', 200, create_order_response)
        stub_send_request('get', 'order?token=qp_token', 200, find_order_response('Approved'))
        payment = create(:payment, response_code: 'qp_token', source: nil)
        run_rake_task
        payment.reload
        expect(payment.completed?).to eq false
      end

      it 'status is failed' do
        payment = create_payment('Approved', 'failed')
        updated_at = payment.updated_at
        run_rake_task
        payment.reload
        expect(payment.completed?).to eq false
        expect(payment.updated_at).to eq updated_at
      end

      it 'status is completed' do
        payment = create_payment('Approved', 'completed')
        updated_at = payment.updated_at
        run_rake_task
        payment.reload
        expect(payment.updated_at).to eq updated_at
      end
    end
  end

  context 'QuadPay Order status' do
    it 'Created – QuadPay Checkout still in progress, re-checking at another cycle' do
      payment = create_payment('Created')
      run_rake_task
      payment.reload
      expect(payment.completed?).to eq false
    end

    it 'Approved – QuadPay Checkout completed then payment complete and order completed' do
      payment = create_payment('Approved')
      run_rake_task
      payment.reload
      expect(payment.completed?).to eq true
    end

    it 'Declined – QuadPay Checkout cancelled then set payment invalid' do
      payment = create_payment('Declined')
      run_rake_task
      payment.reload
      expect(payment.completed?).to eq false
    end

    it 'Abandoned – QuadPay Checkout abandoned then set payment invalid' do
      payment = create_payment('Abandoned')
      run_rake_task
      payment.reload
      expect(payment.completed?).to eq false
    end
  end

  def run_rake_task
    Rake::Task['quad_pay_tasks:sync_orders'].reenable
    Rake.application.invoke_task 'quad_pay_tasks:sync_orders'
  end
end
