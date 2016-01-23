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
		@recent_karaoke = @user.get_karaoke(1)[0]
		column_name = [
			'song', 
			'artist',
			'history'
		]
		table = [
			{
				song: 'song1',
				artist: 'artist1',
				history: 'history1'
			},
			{
				song: 'song2',
				artist: 'artist2',
				history: 'history2'
			}
		]
		template :index, :locals => {column_name: column_name, item: table}
	end

	use AuthenticationRoute
	use KaraokeRoute
	use HistoryRoute
	use SongRoute
	use ArtistRoute
	use RankingRoute
	use UserRoute

end
