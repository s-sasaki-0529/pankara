require_relative './march'
require_relative '../models/user'
require_relative '../models/pager'

class UserRoute < March

  # get '/user/userpage' - ログイン中ユーザのユーザページへリダイレクト
  #---------------------------------------------------------------------
  get '/userpage' do
    if @current_user
      user = @current_user['username']
      redirect "/user/userpage/#{user}"
    end
  end

  # get '/user/userpage/:username' - 指定したユーザのユーザページを表示
  #--------------------------------------------------------------------
  get '/userpage/:username' do
    @user = User.new(params[:username])
    @user.exist? or raise Sinatra::NotFound
    @histories = @user.histories(:limit => 5 , :page => 1 , :song_info => true)
    @karaoke_list = @user.get_karaoke 5
    @most_sang_song = @user.get_most_sang_song
    @max_score = @user.get_max_score
    @songlist = @user.songlist(:sort_category => 'sang_count' , :limit => 10)[:list]
    @users = @user.friend_list(Util::Const::Friend::FRIEND , :want_array => true)
    # 集計情報を自動で表示するオプション
    @show_aggregate = params[:show_aggregate]
    erb :user_page
  end

  # get '/user/songlist' - ログイン中ユーザの持ち歌一覧へリダイレクト
  #--------------------------------------------------------------------
  get '/songlist' do
    if @current_user
      user = @current_user['username']
      redirect "/user/songlist/#{user}"
    end
  end

  # get '/user/songlist/:username' - 指定したユーザの持ち歌一覧を表示
  #--------------------------------------------------------------------
  get '/songlist/:username' do
    @user = User.new(params[:username])
    @user.exist? or raise Sinatra::NotFound
    opt = {}

    # デバイス確認
    @columns = Util.is_pc? ? 2 : 1

    # リセット
    if params[:reset]
      redirect "/user/songlist/#{params[:username]}"
    end

    # ページャ設定
    @pagenum = params[:pagenum] ? params[:pagenum].to_i : 24
    @page = params[:page] ? params[:page].to_i : 1
    @pager = Pager.new(@pagenum , @page)
    opt[:pager] = @pager

    # あなたと共通の持ち歌
    if @current_user && @current_user['username'] != @user['username'] && params[:common]
      @common = true
      opt[:common] = @current_user
    end

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

    # 持ち歌リストを生成
    @song_list = @user.songlist(opt)

    # 表示件数
    @show_from = @pager.current_page * @pagenum - @pagenum + 1
    if @pager.current_page < @pager.page_num
      @show_to = @pager.current_page * @pagenum
    else
      @show_to = (@pager.current_page - 1) * @pagenum + @song_list[:list].size
    end
    erb :song_list
  end

  # get '/user/friend/list/?' - ログイン中ユーザの友達一覧を表示
  #--------------------------------------------------------------------
  get '/friend/list/?' do
    if @current_user
      user = @current_user['username']
      redirect "/user/friend/list/#{user}"
    end
  end

  # get '/user/friend/list/:user/?' - 指定したユーザの友達一覧を表示
  #--------------------------------------------------------------------
  get '/friend/list/:username/?' do
    @user = User.new(params[:username])
    @user.exist? or raise Sinatra::NotFound
    friend_list = @user.friend_list(nil , :want_array => true)

    # 友達
    @friends = friend_list.select {|f| f['status'] == Util::Const::Friend::FRIEND}
    # 申請中
    @follows = friend_list.select {|f| f['status'] == Util::Const::Friend::FOLLOW}
    # 承認待ち
    @followers = friend_list.select {|f| f['status'] == Util::Const::Friend::FOLLOWED}
    erb :friend_list
  end

  # get '/user/aggregate/:username/?' - 指定したユーザの集計情報
  #--------------------------------------------------------------------
  get '/aggregate/:username' do
    @user = User.new(params[:username])
    @user or return error('invalid user id')
    @agg = @user.aggregate(:year => params[:year])
    @year = params[:year]
    @HIDEHEADMENU = true
    erb :user_aggregate
  end

end
