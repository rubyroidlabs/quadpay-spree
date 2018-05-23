require 'spec_helper'

describe 'Spree::BillingIntegration::QuadPayCheckout', type: :model do
  # before :all do
  #   @quad_pay_checkout =
  #     Spree::BillingIntegration::QuadPayCheckout.new(
  #       :name => 'QuadPayCheckout',
  #       # :type => "Spree::BillingIntegration::QuadPayCheckout",
  #       :description => 'QuadPayCheckout',
  #       :active => true,
  #       :display_on => "both",
  #       :preferences => Hash.new(
  #         :client_id => "client_id", 
  #         :client_secret =>"client_secret", 
  #         :server=>"test", 
  #         :test_mode=>"true"
  #       )
  #     )
  # end

  it '#source_required?' do
    # expect(Spree::BillingIntegration::QuadPayCheckout.new.source_required?).to eq false
  end

  it '#auto_capture?' do
    # expect(Spree::BillingIntegration::QuadPayCheckout.new.source_required?).to eq false
  end
end
