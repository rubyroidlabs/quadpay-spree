require 'spec_helper'

describe ActiveMerchant::Billing::QuadPayApi do
  describe 'End Point' do
    context 'test mode' do
      before do
        @quadpay_api = ActiveMerchant::Billing::QuadPayApi.new('id', 'secret', true)
      end

      it 'auth_end_point' do 
        expect(@quadpay_api.auth_end_point).to eq 'https://quadpay-dev.auth0.com/oauth/token'
      end
      it 'auth_audience' do 
        expect(@quadpay_api.auth_audience).to eq 'https://auth-dev.quadpay.com'
      end
      it 'base_url' do 
        expect(@quadpay_api.base_url).to eq 'https://api-ci.quadpay.com'
      end
    end

    context 'live mode' do
      before do
        @quadpay_api = ActiveMerchant::Billing::QuadPayApi.new('id', 'secret', false)
      end

      it 'auth_end_point' do
        expect(@quadpay_api.auth_end_point).to eq 'https://quadpay.auth0.com/oauth/token'
      end
      it 'auth_audience' do 
        expect(@quadpay_api.auth_audience).to eq 'https://auth.quadpay.com'
      end
      it 'base_url' do 
        expect(@quadpay_api.base_url).to eq 'https://api.quadpay.com'
      end
    end
  end

  describe do
  end
end
