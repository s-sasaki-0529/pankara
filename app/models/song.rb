#----------------------------------------------------------------------
# Song - 楽曲に関する情報を操作
#----------------------------------------------------------------------
require_relative 'util'
class Song < Base

  # initialize - インスタンスを生成し、曲名、歌手名を取得する
  #---------------------------------------------------------------------
  def initialize(id)
    @params = DB.new.get('song' , id)
    self.artist
  end

  # list - クラスメソッド 楽曲の一覧を取得
  # opt[:songs] - Array 取得する楽曲をIDで指定
  # opt[:name_like] - String 楽曲名で部分検索
  # opt[:artist_info] - Bool 歌手情報を取得するか
  # opt[:want_hash] - Bool song_idをkeyにしたハッシュに変換
  #--------------------------------------------------------------------
  def self.list(opt = {})
    db = DB.new(:FROM => 'song')
    select = {'song.id' => 'song_id', 'song.name' => 'song_name', 'song.url' => 'song_url'}

    # ArtistInfoも付与
    if opt[:artist_info]
      select.merge!({'artist.id' => 'artist_id', 'artist.name' => 'artist_name'})
      db.join(['song' , 'artist'])
    end
    db.select(select)

    # SongIDを指定
    if songs = opt[:songs]
      db.where_in(['song.id' , songs.length])
      db.set(songs)
    end

    # 楽曲名で部分検索
    if word = opt[:name_like]
      db.where('song.name like ?')
      db.set("%#{word}%")
    end

    # 実行結果を配列、もしくはハッシュで戻す
    list = db.execute_all
    if opt[:want_hash]
      Util.array_to_hash(list , 'song_id')
    else
      list
    end
  end

  # name_to_id - 曲名と歌手名の組み合わせから、song_id / artist_idを戻す
  # 曲名、歌手名の組み合わせはユニークである前提
  #--------------------------------------------------------------------
  def self.name_to_id(song_name , artist_name)
    DB.new(
      :SELECT => {'song.id' => 'song_id', 'artist.id' => 'artist_id'},
      :FROM => 'song',
      :JOIN => ['song' , 'artist'],
      :WHERE => ['song.name = ?' , 'artist.name = ?'],
      :SET => [song_name , artist_name]
    ).execute_row
  end

  # artist - 歌手名を取得
  #---------------------------------------------------------------------
  def artist
    @params.merge! DB.new(
      :SELECT => {'artist.id' => 'artist_id' , 'artist.name' => 'artist_name'} ,
      :FROM => 'song' ,
      :JOIN => ['song' , 'artist'] ,
      :WHERE => 'song.id = ?' ,
      :SET => @params['id']
    ).execute_row
  end

  # sangcount - 歌唱回数を取得
  # :target_user - 指定ユーザの歌唱回数のみ集計する
  # :without_user - 指定ユーザの歌唱回数は数えない
  #---------------------------------------------------------------------
  def sangcount(opt = {})
    db = DB.new(
      :SELECT => {'COUNT(*)' => 'count'} ,
      :FROM => 'history',
      :JOIN => ['history' , 'attendance'] ,
      :WHERE => 'history.song = ?' ,
      :SET => @params['id'] ,
      :OPTION => ['GROUP BY history.song' , 'ORDER BY count DESC']
    )

    #Todo 全体 - 自分 = 自分以外になるのでは！？
    if target = opt[:target_user]
      db.where 'attendance.user = ?'
      db.set target
    elsif without = opt[:without_user]
      db.where 'attendance.user != ?'
      db.set without
    end

    count = db.execute_column
    return (count.nil?) ? 0 : count
  end

  # tally_score - 得点の集計を得る
  # :score_type - 採点モードを指定
  # :target_user - 指定ユーザの得点を集計する
  # :without_user - 指定ユーザの得点は集計に含めない
  #---------------------------------------------------------------------
  def tally_score(opt = {})
    db = DB.new(
      :SELECT => {
        'MAX(history.score)' => 'score_max' ,
        'MIN(history.score)' => 'score_min' ,
        'AVG(history.score)' => 'score_avg' ,
      } ,
      :FROM => 'history',
      :WHERE => 'song = ?' ,
      :SET => @params['id']
    )

    if st = opt[:score_type]
      db.where 'score_type = ?'
      db.set st
    end

    if target = opt[:target_user]
      db.join ['history' , 'attendance']
      db.where 'attendance.user = ?'
      db.set target
    elsif without = opt[:without_user]
      db.join ['history' , 'attendance']
      db.where 'attendance.user != ?'
      db.set without
    end

    db.execute_row
  end

  # history_list - この曲の歌唱履歴を取得
  # useridを省略した場合、全ユーザを対象にする
  #---------------------------------------------------------------------
  def history_list(opt = {})
    db = DB.new(
      :SELECT => {
        'karaoke.id' => 'karaoke_id' ,
        'karaoke.name' => 'karaoke_name' ,
        'karaoke.datetime' => 'datetime' ,
        'user.username' => 'username' ,
        'user.screenname' => 'user_screenname' ,
        'history.songkey' => 'songkey' ,
        'history.score_type' => 'score_type' ,
        'history.score' => 'score'
      } ,
      :FROM => 'history' ,
      :JOIN => [
        ['history' , 'attendance'] ,
        ['attendance' , 'karaoke'] ,
        ['attendance' , 'user'] ,
      ],
      :WHERE => 'history.song = ?' ,
      :SET => @params['id'] ,
      :OPTION => 'ORDER BY karaoke.datetime DESC' ,
    )

    if limit = opt[:limit]
      db.option "LIMIT #{limit}"
    end

    if target = opt[:target_user]
      db.where 'attendance.user = ?'
      db.set target
    end

    if without = opt[:without_user]
      db.where 'attendance.user != ?'
      db.set without
    end

    result = db.execute_all
    result.each do |sang|
      sang['scoretype_name'] = ScoreType.id_to_name(sang['score_type'] , true).values.join("<br>")
    end
    return result
  end

  # modify - 楽曲情報を修正する
  #--------------------------------------------------------------------
  def modify(arg)
    song_arg = arg.select do |k , v|
      ['url'].include?(k)
    end

    DB.new(
      :UPDATE => ['song' , song_arg.keys] ,
      :WHERE => 'id = ?' ,
      :SET => song_arg.values.push(@params['id'])
    ).execute
    @params = DB.new.get('song' , @params['id'])
  end

end
