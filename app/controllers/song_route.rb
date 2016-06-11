require_relative './march'
require_relative '../models/song'
require_relative '../models/score_type'

class SongRoute < March

  # get '/song' - ランダムで１曲表示
  #--------------------------------------------------------------------
  get '/song/' do

    # 楽曲一覧を取得する。ログイン済みの場合そのユーザが歌った曲からのみ
    songs_ids = []
    @current_user and song_ids = @current_user.histories.map {|h| h['song']}.uniq
    if songs_ids.empty?
      song_ids = Song.list.map {|s| s['song_id']}
    end

    # 楽曲一覧よりランダムで１曲取り出してリダイレクト
    if song_ids.empty?
      redirect '/'
    else
      redirect "/song/#{song_ids.sample}"
    end
  end

  # get '/song/:id' - 曲情報を表示
  #---------------------------------------------------------------------
  get '/song/:id' do
    score_type = 1 #現在は仮で固定
    user = @current_user ? @current_user.params['id'] : nil
    @song         = Song.new(params[:id])
    @sangcount    = @song.sangcount({:without_user => user})
    @score        = @song.tally_score({:score_type => score_type , :without_user => user})
    @history      = @song.history_list({:limit => 10 , :without_user => user})
    @score_type_num = ScoreType.List.size
    if user
      @my_sangcount = @song.sangcount({:target_user => user})
      @my_score     = @song.tally_score({:score_type => score_type , :target_user => user})
      @my_history   = @song.history_list({:limit => 10 , :target_user => user})
    end

    erb :song_detail
  end

  
end
