require_relative './march'
require_relative '../models/user'

class AuthenticationRoute < March

  # get '/login' - ログイン画面へのアクセス
  #---------------------------------------------------------------------
  get '/login' do
    erb :login
  end

  # get '/logout' - ログアウトする
  #---------------------------------------------------------------------
  get '/logout' do
    session[:logined] = nil
    redirect '/login'
  end

  # post '/login' - ログインリクエスト
  #---------------------------------------------------------------------
  post '/login' do
    auth = User.authenticate(@params[:username] , @params[:password])
    if auth
      session[:logined] = User.new(@params[:username])
      redirect '/'
    else
      redirect '/login'
    end
  end

  # post '/rpc/login' - RPCログインリクエスト
  #---------------------------------------------------------------------
  post '/rpc/login' do
    auth = User.authenticate(@params[:username] , @params[:password])
    if auth
      user = User.new(@params[:username])
      session[:logined] = user
      userinfo = {:username => user['username'] , :screenname => user['screenname']}
      Util.to_json([{
        :result => 'success' , 
        :username => user['username'] ,
        :screenname => user['screenname']
      }])
    else
      Util.to_json([{:result => 'error'}])
    end
  end

  # get '/user/registration' - ユーザの新規登録画面を表示
  #---------------------------------------------------------------------
  get '/user/registration' do
    erb :user_registration
  end

  # post '/user/registration' - ユーザの登録をリクエスト
  #---------------------------------------------------------------------
  post '/user/registration' do
    if User.new(@params[:username]).params.nil? and @params[:password] == @params[:repassword]
      User.create(@params[:username] , @params[:password] , @params[:screenname])
      erb :registration_successful
    else
      erb :user_registration
    end
  end

end
