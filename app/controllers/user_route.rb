require_relative './march'

class UserRoute < March

  # get '/user/:username' - ユーザページを表示
  #---------------------------------------------------------------------
  get '/user/?' do
    user = @current_user['username']
    redirect "/user/#{user}"
  end
  get '/user/:username' do
    @user = User.new(params[:username])
    @histories = @user.histories 5
    @karaoke_list = @user.get_karaoke 5
    @most_sang_song = @user.get_most_sang_song
    @most_sang_artist = @user.get_most_sang_artist
    @max_score = @user.get_max_score
    erb :user_page
  end

end
