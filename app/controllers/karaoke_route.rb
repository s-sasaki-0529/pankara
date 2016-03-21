require_relative './march'

class KaraokeRoute < March

  # get '/karaoke/list' - 全カラオケ記録を一覧表示
  #---------------------------------------------------------------------
  get '/karaoke/list/?' do
    @karaoke_list = Karaoke.list_all({:with_attendance => true})
    erb :karaokelist
  end

  # get '/karaoke/user' - ログイン中ユーザのカラオケ記録を一覧表示
  #---------------------------------------------------------------------
  get '/karaoke/user/?' do
    @current_user and redirect "/karaoke/user/#{@current_user['username']}"
  end

  # get '/karaoke/user/:username' - 特定ユーザのカラオケ記録を一覧表示
  #---------------------------------------------------------------------
  get '/karaoke/user/:username' do
    @target_user = User.new(params[:username])
    @karaoke_list = @target_user.get_karaoke
    erb :karaokelist
  end

  # get '/karaoke/detail/:id' - カラオケ記録の詳細表示
  #---------------------------------------------------------------------
  get '/karaoke/detail/:id' do
    @karaoke = Karaoke.new(params[:id])
    @karaoke.get_history
    erb :karaoke_detail
  end

end
