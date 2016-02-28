require 'rack/protection'
require './app/controllers/index_route'

use Rack::Session::Cookie, secret: 'secret_key'
use Rack::Protection, raise: true
use Rack::Protection::AuthenticityToken

run IndexRoute.new
