#----------------------------------------------------------------------
# Zenra - ルーティングと各種モデル、ビューの呼び出しを行うクラス
#----------------------------------------------------------------------

require 'sinatra/base'
require_relative 'models/db'
require_relative 'models/user'
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
	end

	# get '/' - トップページへのアクセス
	#---------------------------------------------------------------------
	get '/' do
		erb :index
	end

	# history '/history/:username - ユーザの歌唱履歴を表示
	#---------------------------------------------------------------------
	get '/history/:username' do
		@user = User.new(username: params[:username])
		erb :history
	end
end
