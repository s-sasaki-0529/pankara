#----------------------------------------------------------------------
# Zenra - ルーティングと各種モデル、ビューの呼び出しを行うクラス
#----------------------------------------------------------------------

require 'sinatra/base'
require 'rack/user_agent'
require_relative '../models/util'

class March < Sinatra::Base

  set :views, File.dirname(__FILE__) + '/../views'
  set :public_folder, File.dirname(__FILE__) + '/../public'

  # configure - サーバ起動時の初期設定
  #---------------------------------------------------------------------
  configure do
    use Rack::UserAgent
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
    def date(datetime)
      datetime.to_s.split(' ')[0]
    end
    def csrftoken
      name = 'authenticity_token'
      token = session['csrf']
      return "<input type='hidden' name='#{name}' id='#{name}' value='#{token}'>"
    end
    def movie_player(id , w , h , autoplay = 0) #youtubeのみ対応
      if id
        embed = "https://www.youtube.com/embed/#{id}?autoplay=#{autoplay}"
        return "<iframe width=\"#{w}\" height=\"#{h}\" src=\"#{embed}\"></iframe>"
      else
        return "<a href=\"#{url}\">動画リンク</a>"
      end
    end
    def youtube_image(id)
      if id && id != "" && id != nil
        "http://i.ytimg.com/vi/#{id}/mqdefault.jpg"
      else
        "未登録"
      end
    end
    def user_link(username, screenname , with_icon = true , size = 32 , with_break = nil)
      username = h username
      screenname = h screenname
      link = "/user/userpage/#{username}"
      if with_icon
        img_tag = user_icon(username , "#{size}px" , "#{size}px")
        break_tag = with_break ? "<br>" : ""
        return "#{img_tag}#{break_tag} <a class='userlink' href='#{link}'>#{screenname}</a>"
      else
        return "<a class='userlink' href='#{link}'>#{screenname}</a>"
      end
    end
    def karaoke_link(id, name)
      name = h name
      return "<a href=/karaoke/detail/#{id}>#{name}</a>"
    end
    def song_link(id, name , target="_self")
      name = h name
      return "<a target=#{target} href=/song/#{id}>#{name}</a>"
    end
    def artist_link(id, name)
      name = h name
      return "<a href=/artist/#{id}>#{name}</a>"
    end
    def playlist_link(songs , name = "動画を連続再生する")
      if songs.empty?
        return ""
      else
        param = songs.join('_')
        return "<a href=/playlist?songs=#{param}>#{name}</a>"
      end
    end
    def user_icon(username , width = 32 , height = 32)
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
      session[:logined] = user
    end

    @current_user = User.new(session[:logined]) if session[:logined]

    #セション情報、リクエストパラメータをUtilクラスで参照できるようにする
    Util.set_session session
    Util.set_request request
    Util.write_access_log(@current_user)
  end

end
