require_relative './march'
require_relative '../models/user'
require_relative '../models/pager'
require_relative '../models/attendance'

class HistoryRoute < March

  # get '/history/detail/:id' - 歌唱履歴の詳細を表示
  #--------------------------------------------------------------------
  get '/detail/:id' do
    @HIDEHEADMENU = true
    @history = History.new(params[:id] , true)
    @history or raise Sinatra::NotFound
    @attendance = Attendance.new(@history['attendance'])
    @karaoke = Karaoke.new(@attendance['karaoke'])
    @user = Attendance.to_user_info([@history['attendance']])[0]
    @history.params['score_type_name'] = ScoreType.id_to_name(@history['score_type'])
    erb :history_detail
  end

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
    @user.exist? or raise Sinatra::NotFound
    @histories = @user.histories(opt)

    # 表示範囲の情報
    if @histories.size > 0
      @history_size = @pager.data_num
      @show_from = @pager.data_num - @histories[0]['number'].to_i + 1
      @show_to = @pager.data_num - @histories[-1]['number'].to_i + 1
    end

    erb :history

  end

end
