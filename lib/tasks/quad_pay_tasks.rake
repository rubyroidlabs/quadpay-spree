namespace :quad_pay_tasks do
  task sync_orders: :environment do
    qpms = Spree::BillingIntegration::QuadPayCheckout.available_on_front_end.active
    if qpm = qpms.first
      quad_pay_payments = quad_pay_payments(qpms)
      quad_pay_payments.each do |payment|
        order = payment.order
        quadpay_order = qpm.find_order(payment.response_code)
        if quadpay_order.code == 200
          case quadpay_order.body['orderStatus']
          when 'Created'
            # No action
          when 'Approved'
            payment.update(state: 'processing')
            payment.complete!
            # Force complete order
            while order.next; end
          when 'Declined'
            make_payment_fail(payment)
          when 'Abandoned'
            make_payment_fail(payment)
          else
            make_payment_fail(payment) if payment.created_at < 15.minute.ago
          end
        else
          make_payment_fail(payment) if payment.created_at < 15.minute.ago
        end
      end
    end
  end

  def make_payment_fail(payment)
    payment.update(state: 'processing')
    payment.failure
  end

  def quad_pay_payments(qpms)
    Spree::Payment.
      where(payment_method_id: qpms.ids).
      joins(:order).
      where.not('spree_payments.state IN (?)', %w(failed completed)).
      where('spree_payments.created_at >= ?', 15.minutes.ago)
  end
end
