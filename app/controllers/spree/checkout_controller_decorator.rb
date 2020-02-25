# frozen_string_literal: true

module Spree
  module CheckoutControllerDecorator
    def self.prepended(base)
      base.before_action :confirm_quad_pay, only: [:update]
    end

    private

    def confirm_quad_pay
      unless (params[:state] == 'payment') && params[:order] && params[:order][:payments_attributes]
        return
      end

      payment_method = Spree::PaymentMethod.find(params[:order][:payments_attributes].first[:payment_method_id])
      if payment_method&.is_a?(Spree::BillingIntegration::QuadPayCheckout)
        if qp_order = payment_method.create_order(@order)
          if @order.update_from_params(params, permitted_checkout_attributes, request.headers.env)
            @order.temporary_address = !params[:save_user_address]
            if payment = @order.payments.valid.first
              payment.update(response_code: qp_order['token'])
              payment.quad_pay_orders.create(
                qp_order_id: qp_order['orderId'],
                qp_order_token: qp_order['token']
              )
            end
            redirect_to qp_order['redirectUrl']
          else
            render :edit
          end
        else
          flash[:error] = Spree.t(:quad_pay_checkout_error)
          redirect_to checkout_state_path('payment')
        end
      end
    end
  end
end

Spree::CheckoutController.prepend(Spree::CheckoutControllerDecorator)
