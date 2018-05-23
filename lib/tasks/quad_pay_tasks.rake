namespace :quad_pay_tasks do
  task sync_orders: :environment do
    qpms = Spree::BillingIntegration::QuadPayCheckout.available_on_front_end.active
    if qpm = qpms.first
      quad_pay_payments =
        Spree::Payment.
          where(payment_method_id: qpms.ids).
          joins(:order).
          where("spree_orders.completed_at IS NULL and spree_payments.state IN (?)", %w(pending checkout processing))

      quad_pay_payments.each do |payment|
        order = payment.order
        quadpay_order = qpm.find_order(payment.response_code)
        if quadpay_order.code == 200
          case quadpay_order.body['orderStatus']
          when 'Created'
            # No action
          when 'Approved'
            payment.complete!
            # Force complete order
            while order.next; end
          when 'Declined'
            payment.invalidate
          when 'Abandoned'
            payment.invalidate
          else
            payment.invalidate if payment.created_at < 15.minute.ago
          end
        else
          payment.invalidate if payment.created_at < 15.minute.ago
        end
      end
    end
  end
end
