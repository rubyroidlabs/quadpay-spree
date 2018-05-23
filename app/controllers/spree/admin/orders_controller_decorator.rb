Spree::Admin::OrdersController.class_eval do
  def cancel
    begin
      @order.canceled_by(try_spree_current_user)
      flash[:success] = Spree.t(:order_canceled)
    rescue Exception => e
      flash[:error] = e.to_s
    end
    redirect_to :back
  end
end
