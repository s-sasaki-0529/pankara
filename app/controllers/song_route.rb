require_relative './march'

class SongRoute < March

  # get '/song/:id' - 曲情報を表示
  #---------------------------------------------------------------------
  get '/song/:id' do
    score_type = 1 #現在は仮で固定
    user = @current_user.params['id']
    @song         = Song.new(params[:id])
    @sangcount    = @song.sangcount()
    @score        = @song.tally_score(score_type)
    @history      = @song.history_list({:history => 10 , :other_user => user})
    @my_sangcount = @song.sangcount(user)
    @my_score     = @song.tally_score(score_type , user)
    @my_history   = @song.history_list({:history => 10 , :target_user => user})
    erb :song_detail
  end

  
end
