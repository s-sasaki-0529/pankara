require_relative './march'
require_relative '../models/user'

class UserRoute < March

  # get '/user' - ログイン中ユーザのユーザページへリダイレクト
  #---------------------------------------------------------------------
  get '/' do
    if @current_user
      user = @current_user['username']
      redirect "/user/#{user}"
    end
  end

  # get '/user/:username' - 指定したユーザのユーザページを表示
  get '/:username' do
    @user = User.new(params[:username])
    @histories = @user.histories(:limit => 5 , :page => 1 , :song_info => true)
    @karaoke_list = @user.get_karaoke 5
    @most_sang_song = @user.get_most_sang_song
    @max_score = @user.get_max_score
    erb :user_page
  end

end
