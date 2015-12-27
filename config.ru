require 'rack/protection'
require './app/core'

#use Rack::Session::Cookie, secret: 'secret_key'
#use Rack::Protection, raise: true
#use Rack::Protection::AuthenticityToken

run Core.new
