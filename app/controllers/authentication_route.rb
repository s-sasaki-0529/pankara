require_relative './march'

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
      Util.debug(session[:logined].tweet('@null ログインしたよ'))
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

end
