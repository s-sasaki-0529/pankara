require_relative './march'

class SongRoute < March

  # get '/song/:id' - 曲情報を表示
  #---------------------------------------------------------------------
  get '/song/:id' do
    score_type = 1 #現在は仮で固定
    @song         = Song.new(params[:id])
    @sangcount    = @song.sangcount()
    @score        = @song.tally_score(score_type)
    @history      = @song.history_list(10)
    @my_sangcount = @song.sangcount(@current_user.params['id'])
    @my_score     = @song.tally_score(score_type , @current_user.params['id'])
    @my_history   = @song.history_list(10 , @current_user.params['id'])
    erb :song_detail
  end

  
end
