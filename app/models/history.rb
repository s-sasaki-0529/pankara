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

class History < Base

  # initialize - historyを取得
  #--------------------------------------------------------------------
  def initialize(id , withInfo = false)
    @params = DB.new.get('history' , id)
    @params['score'] and @params['score'] = sprintf('%.2f',@params['score'])
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
    User.new(user_id)
  end

  # karaoke_url - 歌唱履歴が所属するカラオケのURLを取得
  #--------------------------------------------------------------------
  def karaoke_url
    karaoke_id = Attendance.new(@params['attendance'])['karaoke']
    return Karaoke.new(karaoke_id).url
  end

  # tweet_format - 歌唱履歴についてツイートするフォーマットを生成する
  #--------------------------------------------------------------------
  def tweet_format(format)
    @params['song_name'] or self.set_song_info
    format.gsub!(/\$\$song\$\$/ , @params['song_name'])
    format.gsub!(/\$\$artist\$\$/ , @params['artist_name'])
    format.gsub!(/\$\$url\$\$/ , self.karaoke_url)
    format.gsub!(/\$\$key\$\$/ ,@params['songkey'] >= 0 ? "+#{@params['songkey']}" : @params['songkey'].to_s)
    if @params['score'] && @params['score_type']
      format.gsub!(/\$\$score\$\$/ , @params['score'].to_s)
      format.gsub!(/\$\$scoretype\$\$/ , ScoreType.id_to_name(@params['score_type']))
    else
      format.gsub!(/\$\$score\$\$/ , '未採点')
      format.gsub!(/\$\$scoretype\$\$/ , '未採点')
    end
    return format
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
