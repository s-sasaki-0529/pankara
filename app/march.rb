#----------------------------------------------------------------------
# Zenra - ルーティングと各種モデル、ビューの呼び出しを行うクラス
#----------------------------------------------------------------------

require 'sinatra/base'
require_relative 'models/util'

class March < Sinatra::Base

	# configure - サーバ起動時の初期設定
	#---------------------------------------------------------------------
	configure do
		DB.connect
		enable :sessions
	end

	# helpers - コントローラを補佐するメソッドを定義
	#---------------------------------------------------------------------
	helpers do
		def h(content)
			if content.kind_of? String
				content.gsub!(/<(script.*)>(.*)<\/script>/ , '&lt\1&gt\2&lt/script&gt;')
				content.gsub!(/\r\n|\r|\n/, "<br />")
			elsif content.kind_of? Float
				content = sprintf "%.1f" , content
			end
			content
		end
		def tube(url , w , h)
			if url =~ %r|https://www.youtube.com/watch\?v=(.+)$|
				embed = "https://www.youtube.com/embed/#{$1}"
				return "<iframe width=\"#{w}\" height=\"#{h}\" src=\"#{embed}\"></iframe>"
				return "https://www.youtube.com/embed/#{$1}"
			else
				return "<a href=\"#{url}\">動画リンク</a>"
			end
		end
		def user_link(username, screenname)
			link = "/user/#{username}"
			img_tag = user_icon(username , '32px' , '32px')
			return "<a href='#{link}'>#{img_tag} #{screenname}</a>"
		end
		def karaoke_link(id, name)
			return "<a href=/karaoke/detail/#{id}>#{name}</a>"
		end
		def song_link(id, name)
			return "<a href=/song/#{id}>#{name}</a>"
		end
		def artist_link(id, name)
			return "<a href=/artist/#{id}>#{name}</a>"
		end
		def user_icon(username , width , height)
			src = Util.icon_file(username)
			return "<img src='#{src}' alt='ユーザアイコン' width='#{width}' height='#{height}'>"
		end
	end

	# before - 全てのURLにおいて初めに実行される
	#---------------------------------------------------------------------
	before do
		logined = session[:logined]
		path = request.path_info
		unless logined || path == '/login'
			#@current_user = User.new('user1')
			redirect '/login'
		else
			@current_user = logined
		end
	end

	# get '/' - トップページへのアクセス
	#---------------------------------------------------------------------
	get '/' do
		@user = @current_user
		@recent_karaoke = @user.get_karaoke(1)[0]
		erb :index
	end

	# get '/login' - ログイン画面へのアクセス
	#---------------------------------------------------------------------
	get '/login' do
		erb :login
	end

	# get '/logout' - ログアウトする
	#---------------------------------------------------------------------
	get '/logout' do
		session[:logined] = nil
		redirect '/login'
	end

	# get '/song/:id' - 曲情報を表示
	#---------------------------------------------------------------------
	get '/song/:id' do
		score_type = '全国採点オンライン２' #現在は仮で固定
		@song = Song.new(params[:id])
		@song.count_all
		@song.score_all(score_type)
		@song.sang_history_all
		@my_sangcount = @song.count_as(@current_user.params['id'])
		@my_score = @song.score_as(score_type , @current_user.params['id'])
		@my_sang_history = @song.sang_history_as(@current_user.params['id'])
		erb :song_detail
	end

	# get '/artist/:id' - 歌手情報を表示
	#---------------------------------------------------------------------
	get '/artist/:id' do
		@artist = Artist.new(params[:id])
		@artist.songs_with_count(@current_user.params['id'])
		erb :artist_detail
	end
	# get '/karaoke' - カラオケ記録を一覧表示
	#---------------------------------------------------------------------
	get '/karaoke' do
		@karaoke_list = @current_user.get_karaoke
		erb :mykaraoke
	end

	# get '/karaoke/detail/:id' - カラオケ記録の詳細表示
	#---------------------------------------------------------------------
	get '/karaoke/detail/:id' do
		@karaoke = Karaoke.new(params[:id])
		@karaoke.get_history
		erb :karaoke_detail
	end

	# get '/karaoke/create' - カラオケ記録追加ページヘのアクセス
	#---------------------------------------------------------------------
	get '/karaoke/create' do
		erb :create_karaoke
	end

	# get '/ranking/song' - 楽曲の歌唱回数ランキングを表示
	#---------------------------------------------------------------------
	get '/ranking/song' do
		@songs = History.song_ranking(20)
		erb :song_ranking
	end

	# get '/history - ログイン中のユーザの歌唱履歴を表示
	#---------------------------------------------------------------------
	get '/history' do
		@user = @current_user
		@histories = @current_user.histories
		erb :history
	end

	# get '/history/:username - ユーザの歌唱履歴を表示
	#---------------------------------------------------------------------
	get '/history/:username' do
		@user = User.new(params[:username])
		@histories = @user.histories
		erb :history
	end
	
	# get '/user/:username' - ユーザページを表示
	#---------------------------------------------------------------------
	get '/user/:username' do
		@user = User.new(params[:username])
		@histories = @user.histories 5
		@karaoke_list = @user.get_karaoke 5
		@most_sang_song = @user.get_most_sang_song
		@most_sang_artist = @user.get_most_sang_artist
		@max_score = @user.get_max_score
		erb :user_page
	end

	# post '/login' - ログインリクエスト
	#---------------------------------------------------------------------
	post '/login' do
		auth = User.authenticate(@params[:username] , @params[:password])
		if auth
			session[:logined] = User.new(@params[:username])
			redirect '/'
		else
			redirect '/login'
		end
	end

	# post '/karaoke/create' - カラオケ記録追加をリクエスト
	#---------------------------------------------------------------------
	post '/karaoke/create' do
		@current_user.create_karaoke_log(@params)
		redirect '/karaoke'
	end
end
