Spree::Order.class_eval do
  def available_payment_methods
    qpm_ids = Spree::BillingIntegration::QuadPayCheckout.active.ids
    @available_payment_methods ||= 
      if qpm_ids.any? && (self.total < Spree::Config.quad_pay_min_amount.to_f || self.total > Spree::Config.quad_pay_max_amount.to_f)
        Spree::PaymentMethod.available_on_front_end.where.not(id: qpm_ids)
      else
        Spree::PaymentMethod.available_on_front_end
      end
  end
end
