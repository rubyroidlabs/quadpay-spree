require 'spec_helper'

describe "quad_pay_tasks" do
  context 'QuadPay Order status' do
    xit 'Created – QuadPay Checkout still in progress, re-checking at another cycle'
    xit 'Approved – QuadPay Checkout completed then payment complete and order completed'
    xit 'Declined – QuadPay Checkout cancelled then set payment invalid'
    xit 'Abandoned – QuadPay Checkout abandoned then set payment invalid'
  end

  xit 'dont check Quad Pay Order too many times (default timeout 15 minutes from created)'
end
