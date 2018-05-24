namespace :quad_pay_tasks do
  task sync_orders: :environment do
    qpms = Spree::BillingIntegration::QuadPayCheckout.available_on_front_end.active
    if qpm = qpms.first
      quad_pay_payments =
        Spree::Payment.
          where(payment_method_id: qpms.ids).
          joins(:order).
          where.not("spree_payments.state IN (?)", %w(failed completed))
          where('spree_payments.created_at >= ?', 15.minutes.ago)

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
            set_payment_fail(payment)
          when 'Abandoned'
            set_payment_fail(payment)
          else
            set_payment_fail(payment) if payment.created_at < 15.minute.ago
          end
        else
          set_payment_fail(payment) if payment.created_at < 15.minute.ago
        end
      end
    end
  end

  def set_payment_fail(payment)
    payment.update(state: 'processing')
    payment.failure
  end
end
