require_relative './march'
require_relative '../models/user'

class HistoryRoute < March

  # get '/history - ログイン中のユーザの歌唱履歴を表示
  #---------------------------------------------------------------------
  get '/history/?' do
    @current_user and redirect "/history/#{@current_user['username']}"
  end

  # get '/history/:username - ユーザの歌唱履歴を表示
  #---------------------------------------------------------------------
  get '/history/:username' do
    opt = {}
    @user = User.new(params[:username])
    @histories = @user.histories(opt)
    @histories.each do |h|
      h['karaoke_datetime'] = h['karaoke_datetime'].to_s.split(' ')[0]
    end
    erb :history
  end

end
