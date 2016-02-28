require 'rack/protection'
require './app/controllers/index_route'

use Rack::Session::Pool
use Rack::Protection, raise: true
use Rack::Protection::AuthenticityToken

run IndexRoute.new
