require_relative './march'
require_relative '../models/song'
require_relative '../models/score_type'

class SongRoute < March

  # get '/song/random' - ランダムで１曲表示
  #--------------------------------------------------------------------
  get '/random' do
    # 楽曲一覧を取得する。ログイン済みの場合そのユーザが歌った曲からのみ
    song_ids = []
    @current_user and song_ids = @current_user.histories.map {|h| h['song']}.uniq
    if song_ids.empty?
      song_ids = Song.list.map {|s| s['song_id']}
    end
    # 楽曲一覧よりランダムで１曲取り出してリダイレクト
    redirect "/song/#{song_ids.sample}"
  end

  # get '/song' - 楽曲情報を表示(歌手名と曲名をパラメータで指定)
  #---------------------------------------------------------------------
  get '/' do
    name = params[:name]
    artist = params[:artist]
    if name && name.size > 0 && artist && artist.size > 0 && song = Song.name_to_object(name , artist)
      redirect "/song/#{song['id']}"
    else
      raise Sinatra::NotFound
    end
  end

  # get '/song/:id' - 楽曲情報を表示(URLで曲IDを指定)
  #---------------------------------------------------------------------
  get '/:id' do
    score_type = 1 #現在は仮で固定
    user = @current_user ? @current_user.params['id'] : nil
    @song         = Song.new(params[:id])
    @song.exist? or raise Sinatra::NotFound
    @sangcount    = @song.sangcount({:without_user => user})
    @history      = @song.history_list({:without_user => user})
    @score_type_num = ScoreType.List.size
    if user
      @my_sangcount = @song.sangcount(:target_user => user)
      @my_history   = @song.history_list(:target_user => user)
    end
    erb :song_detail
  end

  # get '/song/:id/player' - youtubeプレイヤーを表示する
  #---------------------------------------------------------------------
  get '/:id/player' do
    @url = Song.new(params[:id])['url']
    erb :_player
  end

end
