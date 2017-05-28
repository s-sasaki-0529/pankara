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
  get '/list/:username' do  # Todo 検索フォームの初期化が、持ち歌一覧の部分と同じなのであわせたい

    # User.historiesメソッドへのオプション
    opt = {:song_info => true}

    # 検索条件リセット
    if params[:reset]
      redirect "/history/list/#{params[:username]}"
    end

    # ページャ設定
    @pagenum = params[:pagenum] ? params[:pagenum].to_i : 24
    @page = params[:page] ? params[:page].to_i : 1
    @pager = Pager.new(@pagenum , @page)
    opt[:pager] = @pager

    # 検索設定
    @filter_category = params[:filter_category]
    @filter_word = params[:filter_word]
    if @filter_category && @filter_word && @filter_word.size > 0
      opt[:filter_category] = @filter_category
      opt[:filter_word] = @filter_word
    else
      @filter_category = @filter_word = nil
    end

    # 並び順
    @sort_category = params[:sort_category] || 'first_sang_datetime'
    @sort_order = params[:sort_order] || 'desc'
    opt[:sort_category] = @sort_category
    opt[:sort_order] = @sort_order

    # ユーザクラスから歌唱履歴を取得して一覧表示
    @user = User.new(params[:username])
    @user.exist? or raise Sinatra::NotFound
    @histories = @user.histories(opt)
    @history_size = @pager.data_num

    # 表示件数
    @show_from = (@pager.current_page * @pagenum) - @pagenum + 1
    if @pager.current_page < @pager.page_num
      @show_to = @pager.current_page * @pagenum
    else
      @show_to = (@pager.current_page - 1) * @pagenum + @histories.size
    end

    # 検索条件を保存するlocalStorageのキー
    @local_storage_key = 'history_query'

    erb :history

  end

end
