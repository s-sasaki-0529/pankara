require_relative './march'

class CommonRoute < March

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

  # get '/config' - ユーザ設定ページ
  #--------------------------------------------------------------------
  get '/config/?' do
    erb :config
  end

end
