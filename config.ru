require 'rack/protection'
require './app/march'

#use Rack::Session::Cookie, secret: 'secret_key'
#use Rack::Protection, raise: true
#use Rack::Protection::AuthenticityToken

run March.new
