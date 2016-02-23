require_relative './march'

class AuthenticationRoute < March

  # get '/login' - ログイン画面へのアクセス
  #---------------------------------------------------------------------
  get '/login' do
    erb :login , :layout => false
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

end
