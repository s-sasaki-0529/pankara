require_relative './march'
require_relative '../models/song'
require_relative '../models/score_type'

class SongRoute < March

  # get '/song' - ランダムで１曲表示
  #--------------------------------------------------------------------
  get '/song/' do

    # 楽曲一覧を取得する。ログイン済みの場合そのユーザが歌った曲からのみ
    song_ids = []
    @current_user and song_ids = @current_user.histories.map {|h| h['song']}.uniq
    if song_ids.empty?
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
    @history      = @song.history_list({:without_user => user})
    @score_type_num = ScoreType.List.size
    if user
      @my_sangcount = @song.sangcount(:target_user => user)
      @my_history   = @song.history_list(:target_user => user)
    end
    erb :song_detail
  end

  # post '/song/:id/tag/add' - 楽曲にタグを追加する
  # このURLは非同期で呼び出されるため、リダイレクトはクライアント側で行う
  #--------------------------------------------------------------------
  post '/song/:id/tag/add' do
    @current_user or return
    id = params[:id]
    tag = params[:tag_name]
    song = Song.new(id)
    song and tag and tag != "" and tag.split(/[\s　]/).each do |t|
      song.add_tag(@current_user['id'] , t) or return
    end
  end

  # post '/song/:id/tag/remove' - 楽曲に登録されているタグを削除
  # このURLは非同期で呼び出されるため、リダイレクトはクライアント側で行う
  #--------------------------------------------------------------------
  post '/song/:id/tag/remove' do
    id = params[:id]
    tag = params[:tag_name]
    song = Song.new(id)
    song and tag and tag != "" and song.remove_tag(tag)
  end
  
end
