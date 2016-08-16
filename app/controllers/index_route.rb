require_relative './march'
require_relative './authentication_route'
require_relative './karaoke_route'
require_relative './history_route'
require_relative './song_route'
require_relative './artist_route'
require_relative './ranking_route'
require_relative './user_route'
require_relative './ajax_route'
require_relative './common_route'

class IndexRoute < March

  # get '/' - トップページへのアクセス
  #---------------------------------------------------------------------
  get '/' do
    if @current_user
      @user = @current_user
      @timeline = @user.timeline
      @recent_karaoke = @user.get_karaoke(1)[0]
      @song_list = History.recent_song
      erb :index
    else
      redirect '/login'
    end
  end

  use AuthenticationRoute
  use KaraokeRoute
  use HistoryRoute
  use SongRoute
  use ArtistRoute
  use RankingRoute
  use UserRoute
  use LocalRoute
  use CommonRoute

end
