require_relative './march'
require_relative '../models/user'
require_relative '../models/pager'

class HistoryRoute < March

  # get '/history/list - ログイン中のユーザの歌唱履歴を表示
  #---------------------------------------------------------------------
  get '/list' do
    @current_user and redirect "/history/list/#{@current_user['username']}"
  end

  # get '/history/list/:username - ユーザの歌唱履歴を表示
  #---------------------------------------------------------------------
  get '/list/:username' do

    # ページャ準備
    page = params[:page] ? params[:page].to_i : 1
    @pager = Pager.new(50 , page)
    opt = {:pager => @pager , :song_info => true}

    # ユーザクラスから歌唱履歴を取得して一覧表示
    @user = User.new(params[:username])
    @histories = @user.histories(opt)

    # 表示範囲の情報
    @history_size = @pager.data_num
    @show_from = @pager.data_num - @histories[0]['number'].to_i + 1
    @show_to = @pager.data_num - @histories[-1]['number'].to_i + 1

    erb :history

  end

  # get '/history/create/:karaoke_id' - ダイアログを使わずに歌唱履歴を登録する(スマフォ向け)
  #--------------------------------------------------------------------
  get '/create/:karaoke_id' do
    karaoke_id = params[:karaoke_id]
    karaoke_id or return;
    @current_user or return;
    @score_type = ScoreType.List
    @twitter = @current_user ? @current_user['has_twitter'] : nil
    erb :_input_history
  end

end
