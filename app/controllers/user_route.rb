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
  get '/userpage/:username' do
    @user = User.new(params[:username])
    @histories = @user.histories(:limit => 5 , :page => 1 , :song_info => true)
    @karaoke_list = @user.get_karaoke 5
    @most_sang_song = @user.get_most_sang_song
    @max_score = @user.get_max_score
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
    opt = {}

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

    @song_list = @user.songlist(opt)
    erb :song_list
  end

end
