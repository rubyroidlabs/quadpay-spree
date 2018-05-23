Spree::OrdersController.class_eval do
  before_action :load_quaypay_payment, :only => [:quadpay_confirm, :quadpay_cancel]

  def quadpay_confirm
    if @quadpay_order.body['orderStatus'] == 'Approved'
      @payment.complete!
      # Force complete order
      while @order.next; end

      if @order.completed?
        @current_order = nil
        flash['order_completed'] = true
        flash[:notice] = "#{Spree.t(:quadpay_payment_success)}. #{Spree.t(:order_processed_successfully)}"
        return go_to_order_page
      else
        flash[:error] = Spree.t(:quadpay_payment_fail, :order => @order.number)
        redirect_to checkout_state_path(@order.state)
      end
    else
      flash[:error] = Spree.t(:quadpay_payment_fail, :order => @order.number)
    end
    return go_to_order_page
  end

  def quadpay_cancel
    flash[:error] = Spree.t(:quadpay_payment_cancelled)
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
    @payment = Spree::Payment.find_by(:response_code => params['token'])
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
    flash[:error] = Spree.t(:quadpay_payment_invalid)
    go_to_order_page
  end
end

# TODO: Cleanup after test done
# Success token
# 2b275847-0d1e-41da-9957-7a7aae0bcefe
# <OpenStruct code=200, body={"orderId"=>"ed1a8bb1-d56a-44c9-9c1a-e6f1af4fcd08", "orderStatus"=>"Approved", "amount"=>359.04, "consumer"=>nil, "billing"=>{"addressLine1"=>"4000 Main St.", "addressLine2"=>nil, "suburb"=>nil, "city"=>"Anytown", "postcode"=>"85001", "state"=>"AL"}, "shipping"=>{"addressLine1"=>"123 Test st.", "addressLine2"=>"1", "suburb"=>nil, "city"=>"Somewhere", "postcode"=>"90001", "state"=>"CA"}, "description"=>nil, "items"=>[{"description"=>nil, "name"=>"Ruby on Rails Tote", "sku"=>"ROR-00011", "quantity"=>1, "price"=>15.99}, {"description"=>nil, "name"=>"hiep", "sku"=>"H2", "quantity"=>3, "price"=>25.0}, {"description"=>nil, "name"=>"Promotion", "sku"=>nil, "quantity"=>1, "price"=>-35.69}, {"description"=>nil, "name"=>"Ruby on Rails Baseball Jersey", "sku"=>"ROR-00003", "quantity"=>2, "price"=>19.99}, {"description"=>nil, "name"=>"Spree Bag", "sku"=>"SPR-00012", "quantity"=>2, "price"=>22.99}, {"description"=>nil, "name"=>"Ruby on Rails Baseball Jersey", "sku"=>"ROR-00008", "quantity"=>4, "price"=>19.99}, {"description"=>nil, "name"=>"hiep", "sku"=>"h1", "quantity"=>2, "price"=>20.0}, {"description"=>nil, "name"=>"Ruby on Rails Ringer T-Shirt", "sku"=>"ROR-00015", "quantity"=>3, "price"=>19.99}], "merchant"=>{"redirectConfirmUrl"=>"https://tester-nspired-tech.ngrok.io/orders/quadpay_cancel", "redirectCancelUrl"=>"https://tester-nspired-tech.ngrok.io/orders/quadpay_cancel", "statusCallbackUrl"=>nil}, "merchantReference"=>"R508318305", "taxAmount"=>17.85, "shippingAmount"=>20.0, "token"=>"2b275847-0d1e-41da-9957-7a7aae0bcefe", "promotions"=>nil}>

# refund success
# <OpenStruct code=200, body={"id"=>"ea0bca6e-aaae-4570-a675-28767a538e86", "refundedDateTime"=>"2018-05-21T05:35:57.1806007Z", "merchantReference"=>"c6f32647-03b1-4206-818f-c2e2fe8ae7f8", "amount"=>30.44}>
# <OpenStruct code=200, body={"id"=>"c62a2814-f65b-4038-8349-11222ca0c0a9", "refundedDateTime"=>"2018-05-21T05:37:26.3933443Z", "merchantReference"=>"c6f3ccc2647-03b1-4206-818f-c2e2fe8ae7f8", "amount"=>30.44}>
# <OpenStruct code=200, body={"id"=>"4a14671c-b986-4b70-8fe9-e6ac2728f03c", "refundedDateTime"=>"2018-05-21T05:38:02.5511356Z", "merchantReference"=>"c6f3cc2647-03b1-4206-818f-c2e2fe8ae7f8x2", "amount"=>90.44}>
# refund error
# <OpenStruct code=422, body={'msg' => 'error message}>

# Cancel
# <OpenStruct code=200, body={"orderId"=>"ed1a8bb1-d56a-44c9-9c1a-e6f1af4fcd08", "orderStatus"=>"Created", "amount"=>359.04, "consumer"=>nil, "billing"=>{"addressLine1"=>"4000 Main St.", "addressLine2"=>nil, "suburb"=>nil, "city"=>"Anytown", "postcode"=>"85001", "state"=>"AL"}, "shipping"=>{"addressLine1"=>"123 Test st.", "addressLine2"=>"1", "suburb"=>nil, "city"=>"Somewhere", "postcode"=>"90001", "state"=>"CA"}, "description"=>nil, "items"=>[{"description"=>nil, "name"=>"Ruby on Rails Tote", "sku"=>"ROR-00011", "quantity"=>1, "price"=>15.99}, {"description"=>nil, "name"=>"hiep", "sku"=>"H2", "quantity"=>3, "price"=>25.0}, {"description"=>nil, "name"=>"Promotion", "sku"=>nil, "quantity"=>1, "price"=>-35.69}, {"description"=>nil, "name"=>"Ruby on Rails Baseball Jersey", "sku"=>"ROR-00003", "quantity"=>2, "price"=>19.99}, {"description"=>nil, "name"=>"Spree Bag", "sku"=>"SPR-00012", "quantity"=>2, "price"=>22.99}, {"description"=>nil, "name"=>"Ruby on Rails Baseball Jersey", "sku"=>"ROR-00008", "quantity"=>4, "price"=>19.99}, {"description"=>nil, "name"=>"hiep", "sku"=>"h1", "quantity"=>2, "price"=>20.0}, {"description"=>nil, "name"=>"Ruby on Rails Ringer T-Shirt", "sku"=>"ROR-00015", "quantity"=>3, "price"=>19.99}], "merchant"=>{"redirectConfirmUrl"=>"https://tester-nspired-tech.ngrok.io/orders/quadpay_cancel", "redirectCancelUrl"=>"https://tester-nspired-tech.ngrok.io/orders/quadpay_cancel", "statusCallbackUrl"=>nil}, "merchantReference"=>"R508318305", "taxAmount"=>17.85, "shippingAmount"=>20.0, "token"=>"2b275847-0d1e-41da-9957-7a7aae0bcefe", "promotions"=>nil}>
