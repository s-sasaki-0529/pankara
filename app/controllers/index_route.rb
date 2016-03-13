require_relative './march'
require_relative './authentication_route'
require_relative './karaoke_route'
require_relative './history_route'
require_relative './song_route'
require_relative './artist_route'
require_relative './ranking_route'
require_relative './user_route'
require_relative './local_route'

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
      erb :login
    end
  end

  # get '/player/:id' - youtubeプレイヤーを表示する
  #---------------------------------------------------------------------
  get '/player/:id' do
    @url = Song.new(params[:id])['url']
    erb :_player
  end

  # get '/search/:search_word' - 楽曲/歌手を検索する
  #--------------------------------------------------------------------
  get '/search/?' do
    @search_word = params[:search_word] || ""
    @songs_list = []
    @artist_list = []
    if @search_word.size > 0
      @songs_list.concat(Song.list({:name_like => @search_word}))
      @artist_list.concat(Artist.list({:name_like => @search_word}))
    end
    erb :search
  end

  use AuthenticationRoute
  use KaraokeRoute
  use HistoryRoute
  use SongRoute
  use ArtistRoute
  use RankingRoute
  use UserRoute
  use LocalRoute

end
