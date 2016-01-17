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
		def template(template_name)
			erb template_name
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

end
