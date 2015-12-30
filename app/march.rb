#----------------------------------------------------------------------
# Zenra - ルーティングと各種モデル、ビューの呼び出しを行うクラス
#----------------------------------------------------------------------

require 'sinatra/base'
require_relative 'models/db'
require_relative 'models/user'
require_relative 'models/karaoke'
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

	# get '/karaoke' - カラオケ記録を一覧表示
	#---------------------------------------------------------------------
	get '/karaoke' do
		@karaoke_list = Karaoke.list_all
		erb :karaoke_list
	end

	# get '/karaoke/create' - カラオケ記録追加ページヘのアクセス
	#---------------------------------------------------------------------
	get '/karaoke/create' do
		erb :create_karaoke
	end

	# history '/history/:username - ユーザの歌唱履歴を表示
	#---------------------------------------------------------------------
	get '/history/:username' do
		@user = User.new(username: params[:username])
		@histories = @user.histories
		erb :history
	end

	# post '/login' - ログインリクエスト
	#---------------------------------------------------------------------
	post '/login' do
		auth = User.authenticate(@params[:username] , @params[:password])
		if auth
			session[:logined] = auth['username']
			redirect '/'
		else
			redirect '/login'
		end
	end

end
