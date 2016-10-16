require_relative './march'
require_relative '../models/twitter'

class ConfigRoute < March

  # get '/config' - ユーザ設定ページ
  #--------------------------------------------------------------------
  get '/' do

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

  # get '/config/viewtype' - スマフォアクセス時の表示モードを切り替える'
  #--------------------------------------------------------------------
  get '/viewtype/?' do
    callback = params['callback']
    unless Util.is_smartphone_strictly?
      redirect '/'
    else
      new_mode = ! Util.session['view_pc_mode']
      Util.modify_session('view_pc_mode' , new_mode)
      redirect callback
    end
  end

  # post '/config/icon/?' - アイコンファイルのアップロード
  #--------------------------------------------------------------------
  post '/icon/?' do
    if params[:icon_file] && @current_user
      @mod_icon_result = Util.save_icon_file(params[:icon_file] , @current_user['username'])
    end
    erb :config
  end

  # post '/config/twitter/?' - ツイッター連携の設定を適用
  #--------------------------------------------------------------------
  post '/twitter/?' do

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
