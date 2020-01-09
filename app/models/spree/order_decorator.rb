Spree::Order.class_eval do
  def available_payment_methods
    # NOTE: Customize for Spree 3.0.0
    # See lines 5,6,8,10
    qpm_ids = Spree::BillingIntegration::QuadPayCheckout.where(active: true).ids
    @available_payment_methods ||=
      if qpm_ids.any? && (self.total < Spree::Config.quad_pay_min_amount.to_f || self.total > Spree::Config.quad_pay_max_amount.to_f)
        Spree::PaymentMethod.where(active: true).where.not(id: qpm_ids)
      else
        Spree::PaymentMethod.where(active: true)
      end
  end
end
