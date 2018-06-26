Spree::OrdersController.class_eval do
  before_action :load_quaypay_payment, only: [:quadpay_confirm, :quadpay_cancel]

  def quadpay_confirm
    if @quadpay_order.body['orderStatus'] == 'Approved'
      @payment.complete!
      # Force complete order
      while @order.next; end

      if @order.completed?
        @current_order = nil
        flash['order_completed'] = true
        flash[:notice] = "#{Spree.t(:quadpay_payment_success)} #{Spree.t(:order_processed_successfully)}"
        return go_to_order_page
      else
        flash[:error] = Spree.t(:quadpay_payment_fail, number: @order.number)
        return redirect_to checkout_state_path(@order.state)
      end
    else
      flash[:error] = Spree.t(:quadpay_payment_fail, number: @order.number)
    end
    return go_to_order_page
  end

  def quadpay_cancel
    flash[:notice] = Spree.t(:quadpay_payment_cancelled)
    return go_to_order_page
  end

  private
    def go_to_order_page
      # Because order was completed, so customer must be redirect to order's show page or
      # if order not found we will redirect customer to root page
      url =
        if @payment && @order && @order.complete?
          order_path(@payment.order)
        else
          cart_path
        end
      redirect_to url
    end

    def load_quaypay_payment
      @payment = Spree::Payment.find_by(response_code: params['token'])
      if @payment
        @order = @payment.order
        @quadpay_order = @payment.payment_method.find_order(params['token'])
        if @quadpay_order # log payment
          @payment.log_entries.create(
            details: ActiveMerchant::Billing::Response.new(
              @quadpay_order.code == 200,
              @quadpay_order.body).to_yaml
          )
        end
      end

      return if @quadpay_order && @quadpay_order.code == 200 # keep processing if request success
      flash[:notice] = Spree.t(:quadpay_payment_cancelled)
      go_to_order_page
    end
end
