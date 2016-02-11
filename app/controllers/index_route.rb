require_relative './march'
require_relative './authentication_route'
require_relative './karaoke_route'
require_relative './history_route'
require_relative './song_route'
require_relative './artist_route'
require_relative './ranking_route'
require_relative './user_route'

class IndexRoute < March

	# get '/' - トップページへのアクセス
	#---------------------------------------------------------------------
	get '/' do
		@user = @current_user
		@timeline = @user.timeline
		@recent_karaoke = @user.get_karaoke(1)[0]
		@song_list = History.recent_song
		erb :index
	end

	# get '/_local/dialog'
	#---------------------------------------------------------------------
	get '/_local/dialog' do
		@score_type = ScoreType.List
		erb :_input_history
	end

	# get '/player/:id'
	#---------------------------------------------------------------------
	get '/player/:id' do
		@url = Song.new(params[:id])['url']
		erb :_player
	end

	use AuthenticationRoute
	use KaraokeRoute
	use HistoryRoute
	use SongRoute
	use ArtistRoute
	use RankingRoute
	use UserRoute

end
