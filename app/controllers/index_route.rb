require_relative './march'
require_relative './authentication_route'
require_relative './karaoke_route'
require_relative './history_route'
require_relative './song_route'
require_relative './artist_route'
require_relative './ranking_route'
require_relative './user_route'
require_relative './search_route'
require_relative './config_route'
require_relative './playlist_route'
require_relative './stat_route'
require_relative './ajax/ajax_route'
require_relative './ajax/ajax_user_route'
require_relative './ajax/ajax_song_route'
require_relative './ajax/ajax_artist_route'
require_relative './ajax/ajax_karaoke_route'
require_relative './ajax/ajax_history_route'
require_relative './ajax/ajax_store_route'
require_relative './ajax/ajax_attendance_route'
require_relative './ajax/ajax_dialog_route'

class IndexRoute < March

  # get '/' - トップページへのアクセス
  #---------------------------------------------------------------------
  get '/' do
    if @current_user
      # ログイン中のユーザ情報
      @user = @current_user
      # タイムライン
      @timeline = @user.timeline
      # バスタオル用の楽曲一覧
      @song_list = History.recent_song(:sampling => 30)
      # カラオケ実績の有無
      @has_karaoke = @user.get_karaoke(1).size == 1
      erb :index
    else
      redirect '/auth/login'
    end
  end

  # get '/update' - 更新履歴ページ
  #---------------------------------------------------------------------
  get '/update' do
    @update_info = Util.read_update_info
    erb :update
  end

  # get '/contact' - お問い合わせページ
  #---------------------------------------------------------------------
  get '/contact' do
    @sended = flash[:contact_result]
    erb :contact
  end

end
