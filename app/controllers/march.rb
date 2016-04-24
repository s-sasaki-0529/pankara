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
    include Rack::Utils
    def h(content)
      if content.kind_of? String
        content = escape_html content
      elsif content.kind_of? Float
        content = sprintf "%.2f" , content
      end
      content
    end
    def csrftoken
      name = 'authenticity_token'
      token = session['csrf']
      return "<input type='hidden' name='#{name}' id='#{name}' value='#{token}'>"
    end
    def movie_player(url , w , h)
      if url =~ %r|www.youtube.com/watch\?v=(.+)$|
        embed = "https://www.youtube.com/embed/#{$1}"
        return "<iframe width=\"#{w}\" height=\"#{h}\" src=\"#{embed}\"></iframe>"
      elsif url =~ %r|www.nicovideo.jp/watch/sm([0-9]+)|
        embed = "http://ext.nicovideo.jp/thumb/sm#{$1}"
        iframe = "<iframe width='312' height='176' src='#{embed}' scrolling='no' style='border:solid 1px #CCC;' frameborder='0'>"
        iframe += "<a href='#{url}'></a></iframe>"
        return iframe
      else
        return "<a href=\"#{url}\">動画リンク</a>"
      end
    end
    def youtube_image(url)
      if url =~ %r|https://www.youtube.com/watch\?v=(.+)$|
        "http://i.ytimg.com/vi/#{$1}/mqdefault.jpg"
      elsif url =~ %r|www.nicovideo.jp/watch/sm([0-9]+)|
        "http://tn-skr3.smilevideo.jp/smile?i=#{$1}"
      else
        nil
      end
    end
    def user_link(username, screenname , with_icon = true , size = 32)
      username = h username
      screenname = h screenname
      link = "/user/#{username}"
      if with_icon
        img_tag = user_icon(username , "#{size}px" , "#{size}px")
        return "#{img_tag} <a class='userlink' href='#{link}'>#{screenname}</a>"
      else
        return "<a class='userlink' href='#{link}'>#{screenname}</a>"
      end
    end
    def karaoke_link(id, name)
      name = h name
      return "<a href=/karaoke/detail/#{id}>#{name}</a>"
    end
    def song_link(id, name)
      name = h name
      return "<a href=/song/#{id}>#{name}</a>"
    end
    def artist_link(id, name)
      name = h name
      return "<a href=/artist/#{id}>#{name}</a>"
    end
    def user_icon(username , width , height)
      username = h username
      src = Util.icon_file(username)
      return "<img src='#{src}' alt='ユーザアイコン' width='#{width}' height='#{height}'>"
    end

    def base_url
      default_port = (request.scheme == "http") ? 80 : 443
      port = (request.port == default_port) ? "" : ":#{request.port.to_s}"
      "#{request.scheme}://#{request.host}#{port}"
    end
  end

  # before - 全てのURLにおいて初めに実行される
  #---------------------------------------------------------------------
  before do
    # 自動ログイン(debug用)
    if (!session[:logined] && user = Util.read_config('auto_login'))
      session[:logined] = User.new(user)
    end
    @current_user = session[:logined]

    #リクエストパラメータをUtilクラスで参照できるようにする
    Util.set_request request
  end

end
