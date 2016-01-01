#----------------------------------------------------------------------
# Zenra - ルーティングと各種モデル、ビューの呼び出しを行うクラス
#----------------------------------------------------------------------

require 'sinatra/base'
require_relative 'models/db'
require_relative 'models/user'
require_relative 'models/karaoke'
require_relative 'models/history'
require_relative 'public/scripts/util'

class March < Sinatra::Base

	# configure - サーバ起動時の初期設定
	#---------------------------------------------------------------------
	configure do
		DB.init
		enable :sessions
	end

	# helpers - コントローラを補佐するメソッドを定義
	#---------------------------------------------------------------------
	helpers do
		def h(content)
			content.gsub!(/<(script.*)>(.*)<\/script>/ , '&lt\1&gt\2&lt/script&gt;')
			content.gsub!(/\r\n|\r|\n/, "<br />")
			content
		end
	end

	# before - 全てのURLにおいて初めに実行される
	#---------------------------------------------------------------------
	before do
		logined = session[:logined]
		path = request.path_info
		unless logined || path == '/login'
			redirect '/login'
		else
			@current_user = logined
		end
	end

	# get '/' - トップページへのアクセス
	#---------------------------------------------------------------------
	get '/' do
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
		@song = Song.new(params[:id])
		@song.count_all
		@my_sangcount = @song.count_as(@current_user.params['id'])
		erb :song_detail
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
		@songs = History.song_ranking
		erb :song_ranking
	end

	# get '/history/:username - ユーザの歌唱履歴を表示
	#---------------------------------------------------------------------
	get '/history/:username' do
		@user = User.new(params[:username])
		@histories = @user.histories
		erb :history
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
