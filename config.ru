require 'rack/protection'
require './app/controllers/index_route'

use Rack::Session::Pool, :expire_after => 60 * 60 * 24 * 7
use Rack::Protection, raise: true
use Rack::Protection::AuthenticityToken

map('/') {run IndexRoute.new}
map('/auth') {run AuthenticationRoute.new}
map('/artist') {run ArtistRoute.new}
map('/config') {run ConfigRoute.new}
map('/history') {run HistoryRoute.new}
map('/karaoke') {run KaraokeRoute.new}
map('/playlist') {run PlaylistRoute.new}
map('/ranking') {run RankingRoute.new}
map('/search') {run SearchRoute.new}
map('/song') {run SongRoute.new}
map('/user') {run UserRoute.new}
map('/stat') {run StatRoute.new}

map('/ajax') {run AjaxRoute.new}
map('/ajax/user') {run AjaxUserRoute.new}
map('/ajax/song') {run AjaxSongRoute.new}
map('/ajax/artist') {run AjaxArtistRoute.new}
map('/ajax/karaoke') {run AjaxKaraokeRoute.new}
map('/ajax/history') {run AjaxHistoryRoute.new}
map('/ajax/store') {run AjaxStoreRoute.new}
map('/ajax/attendance') {run AjaxAttendanceRoute.new}
map('/ajax/dialog') {run AjaxDialogRoute.new}
