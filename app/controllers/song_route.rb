require_relative './march'
require_relative '../models/song'

class SongRoute < March

  # get '/song/:id' - 曲情報を表示
  #---------------------------------------------------------------------
  get '/song/:id' do
    score_type = 1 #現在は仮で固定
    user = @current_user ? @current_user.params['id'] : nil
    @song         = Song.new(params[:id])
    @sangcount    = @song.sangcount({:without_user => user})
    @score        = @song.tally_score({:score_type => score_type , :without_user => user})
    @history      = @song.history_list({:limit => 10 , :without_user => user})
    if user
      @my_sangcount = @song.sangcount({:target_user => user})
      @my_score     = @song.tally_score({:score_type => score_type , :target_user => user})
      @my_history   = @song.history_list({:limit => 10 , :target_user => user})
    end

    erb :song_detail
  end

  
end
