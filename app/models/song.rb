#----------------------------------------------------------------------
# Song - 個々の楽曲に関する情報を操作
#----------------------------------------------------------------------
require_relative 'util'
class Song < Base

  # initialize - インスタンスを生成し、曲名、歌手名を取得する
  #---------------------------------------------------------------------
  def initialize(id)
    @params = DB.new.get('song' , id)
    self.artist
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
  # userの指定がない場合、全体を対象とする
  #---------------------------------------------------------------------
  def sangcount(userid = nil)
    db = DB.new(:SELECT => {'COUNT(*)' => 'count'} , :FROM => 'history')
    if userid
      db.join(['history' , 'attendance'])
      db.where(['attendance.user = ?' , 'history.song = ?'])
      db.set([userid , @params['id']])
      db.option(['GROUP BY history.song' , 'ORDER BY count DESC'])
    else
      db.where('song = ?')
      db.set(@params['id'])
    end

    count = db.execute_column
    return (count.nil?) ? 0 : count
  end

  # tally_score - 得点の集計を得る
  # useridの指定がない場合、全体を対象とする
  #---------------------------------------------------------------------
  def tally_score(score_type , userid = nil)
    db = DB.new(
      :SELECT => {
        'MAX(score)' => 'score_max' ,
        'MIN(score)' => 'score_min' ,
        'AVG(score)' => 'score_avg' ,
      } ,
      :FROM => 'history'
    )
    where = ['song = ?' , 'score_type = ?']
    set = [@params['id'] , score_type]

    if userid
      db.join(['history' , 'attendance'])
      where.push 'attendance.id = ?'
      set.push userid
    end
    db.where(where)
    db.set(set)
    db.execute_row
  end

  # history_list - この曲の歌唱履歴を取得
  # useridを省略した場合、全ユーザを対象にする
  #---------------------------------------------------------------------
  def history_list(opt = nil)
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

    if opt[:limit]
      db.set("LIMIT #{limit}")
    end

    if opt[:target_user]
      db.where('attendance.user = ?')
      db.set(opt[:target_user])
    end

    if opt[:other_user]
      db.where('attendance.user != ?')
      db.set(opt[:other_user])
    end

    result = db.execute_all
    result.each do |sang|
      sang['scoretype_name'] = ScoreType.id_to_name(sang['score_type'] , true).values.join("<br>")
    end
    return result
  end

  # self.id_to_info - songIDに対応する曲名、歌手名を取得
  # 複数id対応なので、まとめて行う場合はインスタンスを生成せずにこちらを用いる
  #--------------------------------------------------------------------
  def self.id_to_info(songs , opt = nil)
    songs.kind_of?(Array) or songs = [songs]
    qlist = Util.make_questions(songs.length)
    song_info = DB.new(
      :SELECT => {
        'song.id' => 'song_id' ,
        'song.name' => 'song_name' ,
        'song.url' => 'song_url' ,
        'artist.id' => 'artist_id' ,
        'artist.name' => 'artist_name' ,
      } ,
      :FROM => 'song' ,
      :JOIN => ['song' , 'artist'] ,
      :WHERE => "song.id IN (#{qlist})" ,
      :SET => songs ,
    ).execute_all
    Util.array_to_hash(song_info , 'song_id')
  end

  # self.list - 楽曲一覧を戻す
  #--------------------------------------------------------------------
  def self.list(opt = nil)
    DB.new(
      :SELECT => {
        'song.id' => 'song_id' ,
        'song.name' => 'song_name' ,
        'song.url' => 'song_url' ,
        'artist.id' => 'artist_id' ,
        'artist.name' => 'artist_name' ,
      } ,
      :FROM => 'song' ,
      :JOIN => ['song' , 'artist']
    ).execute_all
  end

end
