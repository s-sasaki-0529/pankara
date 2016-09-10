require_relative './march'
require_relative './authentication_route'
require_relative './karaoke_route'
require_relative './history_route'
require_relative './song_route'
require_relative './artist_route'
require_relative './ranking_route'
require_relative './user_route'
require_relative './ajax_route'
require_relative './search_route'
require_relative './config_route'
require_relative './playlist_route'

class IndexRoute < March

  # get '/' - トップページへのアクセス
  #---------------------------------------------------------------------
  get '/' do
    if @current_user
      @user = @current_user
      @timeline = @user.timeline
      @recent_karaoke = @user.get_karaoke(1)[0]
      @song_list = History.recent_song(:sampling => 30)
      erb :index
    else
      redirect '/auth/login'
    end
  end

end
