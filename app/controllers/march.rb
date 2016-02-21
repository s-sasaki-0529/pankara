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
        content.gsub!('/' , '\/')
        content.gsub!('\"' , '\\\"')
        content.gsub!('\'' , '\\\'')
        content.gsub!('<' , '\x3c')
        content.gsub!('>' , '\x3e')
        content.gsub!(/\r\n|\r|\n/, "<br />")
      elsif content.kind_of? Float
        content = sprintf "%.1f" , content
      end
      content
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
    def movie_image(id , w , h , event = false)
      song = Song.new(id)
      id , name , url , artist = song['id'] , h(song['name']) , song['url'] , h(song['artist_name'])
      if url =~ %r|https://www.youtube.com/watch\?v=(.+)$|
        image_url = "http://i.ytimg.com/vi/#{$1}/mqdefault.jpg"
      elsif url =~ %r|www.nicovideo.jp/watch/sm([0-9]+)|
        image_url = "http://tn-skr3.smilevideo.jp/smile?i=#{$1}"
        $1.to_i > 1000000 and image_url += ".L"
      else
        return 'no image'
      end
      info = "#{name} (#{artist})"
      onclick = "onclick=\"zenra.showDialog('#{info}' , 'player_dialog' , '/player/#{id}' , 'player' , 600)\""
      onmouse = event ? "onmouseover=\"bathtowel.showInfo('#{info}')\"" : ""
      imgtag = "<img class=\"thumbnail\" src=\"#{image_url}\" width=\"#{w}\" height=\"#{h}\">"
      return "<span style=\"padding-right: 0\" href=# target=\"_blank\" #{onclick} #{onmouse}>#{imgtag}</span>"
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
