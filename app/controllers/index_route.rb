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
      @user = @current_user
      @timeline = @user.timeline
      @recent_karaoke = @user.get_karaoke(1)[0]
      @song_list = History.recent_song(:sampling => 30)
      erb :index
    else
      redirect '/auth/login'
    end
  end

  # get '/contact' - お問い合わせページ
  #---------------------------------------------------------------------
  get '/contact' do
    if params[:sended]
      @sended = true
    end
    erb :contact
  end

  # post '/contact' - お問い合わせの送信
  #---------------------------------------------------------------------
  post '/contact' do
    @title = params[:title]
    @name = params[:name]
    @mail = params[:email]
    @contact = h(params[:contact]).gsub(/\n/ , '<br>')
    @HIDELAYOUT = true
    body = erb :_mail_template_contact
    Util.send_mail('お問い合わせフォームより' , body)
    redirect '/contact?sended=1'
  end

end
