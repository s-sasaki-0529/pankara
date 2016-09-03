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
    @karaoke.get_history
    erb :karaoke_detail
  end

  # post '/rpc/karaoke/list' - ユーザのカラオケ一覧をJSONで返却
  #---------------------------------------------------------------------
  #post '/rpc/karaoke/list?' do
  #  target_user = @current_user
  #  if target_user
  #    karaoke_list = target_user.get_karaoke
  #    karaoke_list.each do |k|
  #      k['url'] = "http://#{request.host}/karaoke/detail/#{k['id']}"
  #    end
  #    Util.to_json(karaoke_list)
  #  else
  #    Util.to_json([])
  #  end
  #end

  # post '/rpc/karaoke/detail/:id' - カラオケの詳細をJSONで返却
  #---------------------------------------------------------------------
  #post '/rpc/karaoke/detail/?' do
  #  karaoke = Karaoke.new(params[:id])
  #  karaoke.get_history
  #
  #  histories = Hash.new {|h,k| h[k] = Array.new}
  #  karaoke.histories.each do |h|
  #    sname = h['userinfo']['screenname']
  #    h.delete('userinfo')
  #    histories[sname] << h
  #  end
  #  Util.to_json(histories)
  #end

end
