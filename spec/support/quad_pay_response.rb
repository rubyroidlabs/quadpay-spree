module QuadPayResponse
  def configuration_response
    {
      "minimumAmount": 50,
      "maximumAmount": 950
    }
  end

  def create_order_response
    {
      "token": "qp_token",
      "expiryDateTime": "2018-05-31T04:49:23.4122937Z",
      "redirectUrl": "https://checkout-ci.quadpay.com/checkout?token=qp_token",
      "orderId": "qp_order_id"
    }
  end

  def find_order_response(status = 'Created')
    {
      "orderId": "qp_order_id",
      "orderStatus":  status,
      "amount": 359.04,
      "consumer": "nil",
      "billing": {
        "addressLine1": "4000 Main St.",
        "addressLine2": "nil",
        "suburb": "nil",
        "city": "Anytown",
        "postcode": "85001",
        "state": "AL"
      },
      "shipping": {
        "addressLine1": "123 Test st.",
        "addressLine2": "1",
        "suburb": "nil",
        "city": "Somewhere",
        "postcode": "90001",
        "state": "CA"
      },
      "description": "nil",
      "items": [
        {
          "description": "nil",
          "name": "Ruby on Rails Tote",
          "sku": "ROR-00011",
          "quantity": 1,
          "price": 15.99
        },
        {
          "description": "nil",
          "name": "hiep",
          "sku": "H2",
          "quantity": 3,
          "price": 25.0
        },
        {
          "description": "nil",
          "name": "Promotion",
          "sku": "nil",
          "quantity": 1,
          "price": -35.69
        },
        {
          "description": "nil",
          "name": "Ruby on Rails Baseball Jersey",
          "sku": "ROR-00003",
          "quantity": 2,
          "price": 19.99
        },
        {
          "description": "nil",
          "name": "Spree Bag",
          "sku": "SPR-00012",
          "quantity": 2,
          "price": 22.99
        },
        {
          "description": "nil",
          "name": "Ruby on Rails Baseball Jersey",
          "sku": "ROR-00008",
          "quantity": 4,
          "price": 19.99
        },
        {
          "description": "nil",
          "name": "hiep",
          "sku": "h1",
          "quantity": 2,
          "price": 20.0
        },
        {
          "description": "nil",
          "name": "Ruby on Rails Ringer T-Shirt",
          "sku": "ROR-00015",
          "quantity": 3,
          "price": 19.99
        }
      ],
      "merchant": {
        "redirectConfirmUrl": "https://tester-nspired-tech.ngrok.io/orders/quadpay_confirm",
        "redirectCancelUrl": "https://tester-nspired-tech.ngrok.io/orders/quadpay_cancel",
        "statusCallbackUrl": "nil"
      },
      "merchantReference": "R508318305",
      "taxAmount": 17.85,
      "shippingAmount": 20.0,
      "token": "2b275847-0d1e-41da-9957-7a7aae0bcefe",
      "promotions": "nil"
    }
  end

  def refund_response(amount)
    {
      "id": "c62a2814-f65b-4038-8349-11222ca0c0a9",
      "refundedDateTime": "2018-05-21T05:37:26.3933443Z",
      "merchantReference": "c6f3ccc2647-03b1-4206-818f-c2e2fe8ae7f8",
      "amount": amount
    }
  end
end
