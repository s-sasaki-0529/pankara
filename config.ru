require 'rack/protection'
require './app/controllers/index_route'

use Rack::Session::Pool, :expire_after => 60 * 60 * 24 * 7
use Rack::Protection, raise: true
use Rack::Protection::AuthenticityToken

map('/') {run IndexRoute.new}
map('/ajax') {run AjaxRoute.new}
map('/auth') {run AuthenticationRoute.new}
map('/artist') {run ArtistRoute.new}
map('/config') {run ConfigRoute.new}
map('/history') {run HistoryRoute.new}
map('/karaoke') {run KaraokeRoute.new}
map('/ranking') {run RankingRoute.new}
map('/search') {run SearchRoute.new}
map('/song') {run SongRoute.new}
map('/user') {run UserRoute.new}
