#----------------------------------------------------------------------
# History - 個々の歌唱履歴に関する情報を操作
#----------------------------------------------------------------------
require_relative 'base'
require_relative 'util'
require_relative 'db'
require_relative 'user'
require_relative 'song'
require_relative 'register'
require_relative 'attendance'
require_relative 'score_type'

class History < Base

  # initialize - historyを取得
  #--------------------------------------------------------------------
  def initialize(id , withInfo = false)
    @params = DB.new.get('history' , id)
    if @params['score'] && @params['score_type']
      @params['score'] = @params['score'].round(2)
      @params['score_type_name'] = ScoreType.id_to_name(@params['score_type'])
    end
    withInfo and self.set_song_info
  end

  # set_song_info - 楽曲情報をparamsにセットする
  #--------------------------------------------------------------------
  def set_song_info
    songInfo = Song.new(@params['song']).params
    @params['song_name'] = songInfo['name']
    @params['artist_id'] = songInfo['artist']
    @params['artist_name'] = songInfo['artist_name']
    @params['url'] = songInfo['url']
  end

  # modify - カラオケレコードを修正する
  #--------------------------------------------------------------------
  def modify(arg)

    # 曲名、歌手名からsongidを取得
    if arg['song_name'] && arg['artist_name']
      r = Register.new
      artist_id = r.create_artist(arg['artist_name'])
      song_id = r.create_song(artist_id , arg['artist_name'] , arg['song_name'])
      arg['song'] = song_id
    end

    if arg['score_type'].nil? || arg['score_type'].to_s == "0" || arg['score'].nil? || arg['score'].to_i == 0
      arg['score_type'] = nil
      arg['score'] = nil
    end

    if arg['satisfaction_level'].to_i == 0
      arg['satisfaction_level'] = nil
    end

    arg.select! do |k , v|
      ['attendance' , 'song' , 'songkey' , 'satisfaction_level' ,  'score_type' , 'score'].include?(k)
    end

    DB.new(
      :UPDATE => ['history' , arg.keys] ,
      :WHERE => 'id = ?' ,
      :SET => arg.values.push(@params['id'])
    ).execute
    old_params = @params
    @params = DB.new.get('history' , old_params['id'])
    Util.write_log('event' , "【歌唱履歴修正】#{old_params} → #{@params}")
    return true
  end

  # delete - カラオケレコードを削除する
  #--------------------------------------------------------------------
  def delete()
    song = Song.new(@params['song'])
    DB.new(:DELETE => 1 , :FROM => 'history' , :WHERE => 'id = ?' , :SET => @params['id']).execute
    Util.write_log('event' , "【歌唱履歴削除】#{@params} / #{song.params}")
    @params = nil
  end

  # user - 歌唱履歴を登録したユーザを取得
  #--------------------------------------------------------------------
  def user(opt = {})
    user_id = Attendance.new(@params['attendance'])['user']
    opt[:id_only] and return user_id
    User.new(id: user_id)
  end

  # karaoke_url - 歌唱履歴が所属するカラオケのURLを取得
  #--------------------------------------------------------------------
  def karaoke_url
    karaoke_id = Attendance.new(@params['attendance'])['karaoke']
    return Karaoke.new(karaoke_id).url
  end

  # result - 歌唱履歴に関する各種集計結果を取得
  # 計算コストが高いメソッドなので同時多数では呼ばないように
  #--------------------------------------------------------------------
  def result(opt = {})
    user = self.user
    histories = Song.new(@params['song']).history_list(target_user: user['id'])

    # 何(カラオケ/日)ぶりの歌唱か
    if histories.count >= 2
      since_karaoke = Attendance.get_difference_by_user(user['id'], histories[1]['attendance_id'], histories[0]['attendance_id'])
      since_days = Util.date_diff(histories[0]['datetime'].to_s , histories[1]['datetime'].to_s)
      # 何カラオケ連続か
      if since_karaoke == 1
        sang_attends = histories.map {|h| h['attendance_id']}.uniq
        user_attends = user.get_attends(sang_attends.length).map {|a| a['id']}
        if sang_attends == user_attends
          continuous_karaoke_times = sang_attends.length
        else
          continuous_karaoke_times = sang_attends.each_with_index.find_index { |val, i| val != user_attends[i] }
        end
      # 本日何回目か
      elsif since_karaoke == 0
        todays_count = histories.select {|h| h['attendance_id'] == histories[0]['attendance_id']}.count
      end
    else
      since_karaoke = 0
      since_days    = 0
    end

    # この曲の最高得点
    if @params['score_type'] && @params['score']
      max_score_history = histories.select {|h| h['score_type'] == @params['score_type'] && h['history_id'] != @params['id']}
                    .max {|a, b| a['score'] <=> b['score']}
      max_score = max_score_history ? max_score_history['score'].round(2) : nil
    else
      max_score = nil
    end

    return {
      sang_count:       histories.count,
      total_sang_count: user.histories.count,
      since_days:       since_days,
      since_karaoke:    since_karaoke,
      max_score:        max_score,
      continuous_karaoke_times: continuous_karaoke_times,
      todays_count:     todays_count,
    }
  end

  # recent_song - 最近歌われた楽曲のリストを戻す
  #---------------------------------------------------------------------
  def self.recent_song(opt = {})
    # 最近20件のhistoryを取得
    # その楽曲名、歌手名、URLを取得
    db = DB.new(
      :DISTINCT => true ,
      :SELECT => 'song' ,
      :FROM => 'history' ,
      :OPTION => ['ORDER BY history.id DESC']
    )
    songs = db.execute_columns
    songs.empty? and return []

    # [オプション] 取得した楽曲一覧からランダムにいくつか抜き出す
    if opt[:sampling]
      songs = songs.sample(opt[:sampling])
    end

    songs_info = DB.new(
      :SELECT => {
          'song.id' => 'id' ,
          'song.name' => 'name' ,
          'song.url' => 'url' ,
          'artist.name' => 'artist'
      } ,
      :FROM => 'song' ,
      :JOIN => ['song' , 'artist'] ,
      :WHERE => 'song.url IS NOT NULL' ,
      :WHERE_IN => ['song.id' , songs.length] ,
      :SET => songs
    ).execute_all
    songs_info.empty? and return []
    return songs_info
  end

end
