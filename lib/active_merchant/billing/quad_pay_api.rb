require 'net/http'
require 'uri'
require 'json'

module ActiveMerchant
  module Billing
    class QuadPayApi
      attr_accessor :client_id, :client_secret, :test_mode

      def initialize(client_id, client_secret, test_mode)
        @client_id = client_id
        @client_secret = client_secret
        @test_mode = test_mode
      end

      def auth_end_point
        @auth_end_point ||=
          if @test_mode
            'https://quadpay-dev.auth0.com/oauth/token'
          else
            'https://quadpay.auth0.com/oauth/token'
          end
      end

      def auth_audience
        @auth_audience ||=
          if @test_mode
            'https://auth-dev.quadpay.com'
          else
            'https://auth.quadpay.com'
          end
      end

      def base_url
        @base_url ||=
          if @test_mode
            'https://api-ci.quadpay.com'
          else
            'https://api.quadpay.com'
          end
      end
      
      def send_request(method_type = 'get', path = '', body = {})
        method_types = {
          'get' => Net::HTTP::Get,
          'post' => Net::HTTP::Post,
          'put' => Net::HTTP::Patch,
          'delete' => Net::HTTP::Delete
        }

        uri = URI.parse("#{base_url}/#{path}")
        request = method_types[method_type.downcase].new(uri)
        request.content_type = "application/json"
        request['Authorization'] = "Bearer #{access_token}"
        request.body = JSON.dump(body) if body.present?

        response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: (uri.scheme == 'https')) do |http|
          http.request(request)
        end

        body_json = (response.body.present? ? JSON.parse(response.body) : {}) rescue {'msg' => response.body}
        OpenStruct.new(code: response.code.to_i, body: body_json)
      end
      
      def access_token
        return @access_token if @access_token.present?

        uri = URI.parse(auth_end_point)
        request = Net::HTTP::Post.new(uri)
        request.basic_auth(@client_id, @client_secret)
        request['Accept'] = 'application/json'
        request['Accept-Language'] = 'en_US'
        request.set_form_data(
          'audience' => auth_audience,
          'grant_type' => 'client_credentials'
        )

        response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
          http.request(request)
        end

        @access_token = JSON.parse(response.body)['access_token'] 
      end
    end
  end
end
