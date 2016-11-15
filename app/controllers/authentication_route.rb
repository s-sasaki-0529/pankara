require_relative './march'
require_relative '../models/user'

class AuthenticationRoute < March

  # get '/auth/login' - ログイン画面へのアクセス
  #---------------------------------------------------------------------
  get '/login' do
    if @current_user
      redirect '/'
    else
      @callback = params[:callback]
      @update_info = Util.read_update_info[0 , 5]
      @song_list = History.recent_song(:sampling => 30)
      @login_message = flash[:login_message]
      erb :login
    end
  end

  # get '/auth/logout' - ログアウトする
  #---------------------------------------------------------------------
  get '/logout' do
    session[:logined] = nil
    flash[:login_message] = 'ログアウトが完了しました'
    redirect '/auth/login'
  end

  # get '/auth/registration' - ユーザの新規登録画面を表示
  #---------------------------------------------------------------------
  get '/registration' do
    erb :user_registration
  end

  # post '/auth/login' - ログインリクエスト
  #---------------------------------------------------------------------
  post '/login' do
    auth = User.authenticate(@params[:username] , @params[:password])
    if auth
      session[:logined] = @params[:username]
      redirect params[:callback]
    else
      flash[:login_message] = 'IDまたはパスワードが正しいかチェックしてください'
      redirect Util.request.url
    end
  end

  # post '/auth/registration' - ユーザの登録をリクエスト
  #---------------------------------------------------------------------
  post '/registration' do
    if @params[:password] == @params[:repassword]
      ret = User.create(@params[:username] , @params[:password] , @params[:screenname])

      if ret[:result] == 'successful' 
        erb :registration_successful
      else
        @params[:reason] = ret[:info]
        erb :user_registration
      end
    else
      @params[:reason] = '再入力したパスワードが異なっています。'
      erb :user_registration
    end
  end

end
