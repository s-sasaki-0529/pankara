require_relative './march'
require_relative '../models/karaoke'

class KaraokeRoute < March

  # get '/karaoke/list' - 全カラオケ記録を一覧表示
  #---------------------------------------------------------------------
  get '/list/?' do
    @karaoke_list = Karaoke.list_all({:with_attendance => true})
    erb :karaokelist
  end

  # get '/karaoke/user' - ログイン中ユーザのカラオケ記録を一覧表示
  #---------------------------------------------------------------------
  get '/user/?' do
    @current_user and redirect "/karaoke/user/#{@current_user['username']}"
  end

  # get '/karaoke/recent' - ログイン中ユーザの前回のカラオケを表示
  #--------------------------------------------------------------------
  get '/recent/?' do
    @current_user or raise Sinatra::NotFound
    recent_karaoke = @current_user.get_karaoke(1)[0]
    recent_karaoke or raise Sinatra::NotFound
    redirect "/karaoke/detail/#{recent_karaoke['id']}"
  end

  # get '/karaoke/user/:username' - 特定ユーザのカラオケ記録を一覧表示
  #---------------------------------------------------------------------
  get '/user/:username' do
    @target_user = User.new(params[:username])
    @karaoke_list = @target_user.get_karaoke.sort{|a ,b| b['karaoke_datetime'] <=> a['karaoke_datetime']}
    erb :karaokelist
  end

  # get '/karaoke/detail/:id' - カラオケ記録の詳細表示
  #---------------------------------------------------------------------
  get '/detail/:id' do
    @karaoke = Karaoke.new(params[:id])
    @karaoke.exist? or raise Sinatra::NotFound
    @karaoke.get_history
    erb :karaoke_detail
  end

end
