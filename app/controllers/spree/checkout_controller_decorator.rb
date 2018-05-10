Spree::CheckoutController.class_eval do
  before_filter :confirm_quad_pay, only: [:update]

  def quadpay_cancel
    # using param['token'] to query order status
  end

  def quadpay_confirm
    # using param['token'] to query order status
    # flash[:error] = Spree.t(:payment_has_been_cancelled)
    # redirect_to edit_order_path(@order)
  end

  private
    def confirm_quad_pay
      return unless (params[:state] == 'payment') && params[:order] && params[:order][:payments_attributes]

      payment_method = Spree::PaymentMethod.find(params[:order][:payments_attributes].first[:payment_method_id])
      if payment_method.kind_of?(Spree::BillingIntegration::QuadPayCheckout)
        # TODO: Choose one of them
        #   Logic 1: Complete order and redirect
        #   Logic 2: Complete order after User confirm payment

        if redirect_url = payment_method.redirect_url(@order)
          redirect_to redirect_url
        else
          redirect_to edit_order_checkout_url(@order, state: 'payment'),
                      notice: Spree.t(:quad_pay_checkout_error)
        end
      end
    end
end
