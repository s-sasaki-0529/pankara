require_relative './march'
require_relative '../models/song'
require_relative '../models/twitter'
require_relative '../models/tag'

class CommonRoute < March

  # get '/player/:id' - youtubeプレイヤーを表示する
  #---------------------------------------------------------------------
  get '/player/:id' do
    @url = Song.new(params[:id])['url']
    erb :_player
  end

  # get '/search/keyword/:search_word' - 楽曲/歌手を検索する
  #--------------------------------------------------------------------
  get '/search/keyword/?' do
    @search_word = params[:search_word] || ""
    @song_list = []
    @artist_list = []
    @tag_list = []

    if @search_word.size > 0
      # 該当する楽曲、歌手、タグの一覧を取得
      @song_list.concat(Song.list({:name_like => @search_word , :artist_info => true}))
      @artist_list.concat(Artist.list({:name_like => @search_word}))
      @tag_list.concat(Tag.tags(:like => @search_word))

      # 楽曲、歌手、タグ全て合わせて１件しかヒットしなかった場合、そのページにリダイレクト
      if @song_list.size + @artist_list.size + @tag_list.size == 1
        if @song_list.size == 1
          redirect "/song/#{@song_list[0]['song_id']}"
        elsif @artist_list.size == 1
          redirect "/artist/#{@artist_list[0]['id']}"
        else
          redirect "/search/tag/?tag=#{@tag_list[0]}"
        end
      end
    end

    erb :search
  end

  # get '/search/tag/' - タグ検索
  # 現在は楽曲のみにタグが振られていることを想定
  #--------------------------------------------------------------------
  get '/search/tag/' do
    @tag = params[:tag] || ""
    @song_list = []
    if @tag.size > 0
      song_ids = Tag.search('s' , @tag)
      song_ids.size > 0 and @song_list = Song.list(:artist_info => true, :songs => song_ids)
    end
    erb :search_tag
  end

  # get '/config' - ユーザ設定ページ
  #--------------------------------------------------------------------
  get '/config/?' do

    #TwitterAPIからのリダイレクト
    if params[:oauth_token] && verifier = params[:oauth_verifier]
      req_token = session[:request_token] || ''
      req_secret = session[:request_token_secret] || ''
      twitter = Twitter.new(@current_user['username'])
      twitter.get_access_token(req_token , req_secret , verifier)
      redirect '/config/'
    end

    # Twitterの認証状態を取得
    twitter = Twitter.new(@current_user['username'])
    if twitter.authed
      @twitter_authed = true
      @twitter_username = twitter.username
      @twitter_icon = twitter.icon
    end

    erb :config
  end

  # post '/config/icon/?' - アイコンファイルのアップロード
  #--------------------------------------------------------------------
  post '/config/icon/?' do
    if params[:icon_file] && @current_user
      @mod_icon_result = Util.save_icon_file(params[:icon_file] , @current_user['username'])
    end
    erb :config
  end

  # post '/config/twitter/?' - ツイッター連携の設定を適用
  #--------------------------------------------------------------------
  post '/config/twitter/?' do

    username = @current_user['username']

    # Twitter認証リクエスト
    if params[:start_oauth]
      twitter = Twitter.new(username)
      request_token = twitter.request_token("#{base_url}/config")
      session[:request_token] = request_token.token
      session[:request_token_secret] = request_token.secret
      redirect request_token.authorize_url
    # Twitter認証解除リクエスト
    elsif params[:remove_oauth]
      Util.write_secret(username , nil)
      redirect '/config/'
    end
    erb :config
  end

end
