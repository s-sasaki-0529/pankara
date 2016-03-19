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

    # Twitter認証成功の場合
    if params[:oauth_token] && verifier = params[:oauth_verifier]
      req_token = session[:request_token] || ''
      req_secret = session[:request_token_secret] || ''
      twitter = Twitter.new(@current_user['username'])
      twitter.get_access_token(req_token , req_secret , verifier)
      twitter.tweet('TwitterAPIからの投稿')
    end

    erb :config
  end

  # post '/config/?' - ユーザ設定ページ 設定を適用
  #--------------------------------------------------------------------
  post '/config/?' do

    # Twitter認証リクエスト
    if params[:start_oauth]
      twitter = Twitter.new(@current_user['username'])
      request_token = twitter.request_token("#{base_url}/config")
      session[:request_token] = request_token.token
      session[:request_token_secret] = request_token.secret
      redirect request_token.authorize_url
    end

    erb :config
  end

end
