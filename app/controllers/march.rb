#----------------------------------------------------------------------
# Zenra - ルーティングと各種モデル、ビューの呼び出しを行うクラス
#----------------------------------------------------------------------

require 'sinatra/base'
require_relative '../models/util'

class March < Sinatra::Base

	set :views, File.dirname(__FILE__) + '/../views'
	set :public_folder, File.dirname(__FILE__) + '/../public'

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
		def user_link(username, screenname , with_icon = true , size = 32)
			link = "/user/#{username}"
			if with_icon
				img_tag = user_icon(username , "#{size}px" , "#{size}px")
				return "#{img_tag} <a href='#{link}'>#{screenname}</a>"
			else
				return "<a href='#{link}'>#{screenname}</a>"
			end
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
		# 自動ログイン(debug用)
		if (!session[:logined] && user = Util.read_config('auto_login'))
			session[:logined] = User.new(user)
		end

		# ログイン状況を検出
		logined = session[:logined]
		path = request.path_info
		unless logined || path == '/login'
			redirect '/login'
		else
			@current_user = logined
		end
	end

end
