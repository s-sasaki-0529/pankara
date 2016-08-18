require 'rack/protection'
require './app/controllers/index_route'

use Rack::Session::Pool, :expire_after => 60 * 60 * 24 * 7
use Rack::Protection, raise: true
use Rack::Protection::AuthenticityToken

run IndexRoute.new
