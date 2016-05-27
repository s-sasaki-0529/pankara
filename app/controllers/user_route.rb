require_relative './march'
require_relative '../models/user'

class UserRoute < March

  # get '/user/:username' - ユーザページを表示
  #---------------------------------------------------------------------
  get '/user/?' do
    if @current_user
      user = @current_user['username']
      redirect "/user/#{user}"
    end
  end
  get '/user/:username' do
    @user = User.new(params[:username])
    @histories = @user.histories(:limit => 5 , :page => 1)
    @karaoke_list = @user.get_karaoke 5
    @most_sang_song = @user.get_most_sang_song
    @most_sang_artist = @user.favorite_artists(:limit => 1)[0]
    @max_score = @user.get_max_score
    erb :user_page
  end

end
