require 'webmock/rspec'

module QuadPayApiStub
  def stub_send_request(type = 'get', path = '', status = 200, body = {})
    stub_access_token
    full_url = "https://api-ci.quadpay.com/#{path}"
    response = {
      status: status,
      body: body.to_json
    }

    stub_request(type.downcase.to_sym, full_url)
      .with(
        headers: {
          'Accept'=>'*/*',
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Authorization'=>'Bearer token',
          'Content-Type'=>'application/json',
          'Host'=>'api-ci.quadpay.com',
          'User-Agent'=>'Ruby'
        }
      ).to_return(response)
  end

  def stub_access_token
    stub_request(:post, 'https://quadpay-dev.auth0.com/oauth/token').to_return({
      status: 200,
      body: {
        access_token: 'token'
      }.to_json
    })
  end
end
