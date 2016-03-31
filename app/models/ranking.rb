#----------------------------------------------------------------------
# Ranking - 各種ランキングを生成するクラス
#----------------------------------------------------------------------
require_relative 'util'
class Ranking < Base

  # score - クラスメソッド: 得点のランキングを取得
  #--------------------------------------------------------------------
  def self.score(opt = {})
    score_type = opt[:score_type] || 1
    limit = opt[:limit] || 20
    user = opt[:user] || nil

    # history/attendanceテーブルを対象にランキングを取得
    db = DB.new(
      :SELECT => ['user' , 'song' , 'score_type' , 'score'] ,
      :FROM => 'history' ,
      :JOIN => ['history' , 'attendance'] ,
      :WHERE => ['score_type = ?' , 'score IS NOT NULL'] ,
      :OPTION => ['ORDER BY score DESC' , "limit #{limit}"] ,
      :SET => score_type
    )
    # ユーザ指定がある場合そのユーザのみを対象に
    if user
      attends = user.attend_ids
      db.where_in(['history.attendance' , attends.length])
      db.set(attends)
    end

    ranking = db.execute_all

    #該当データがない場合空配列を戻す
    ranking.empty? and return []

    #useridからユーザ情報を取得する
    users = ranking.collect {|row| row['user']}
    users_info = User.id_to_name(users.uniq)

    #songから楽曲情報を取得
    songs = ranking.collect {|row| row['song']}
    songs_info = Song.id_to_info(songs.uniq)

    #各種情報をランキングにマージ
    ranking.each do |row|
      row.merge! users_info[row['user']]
      row.merge! songs_info[row['song']]
    end
    return ranking
  end

  # sang_count - クラスメソッド: 楽曲の歌唱数ランキングを取得
  #--------------------------------------------------------------------
  def self.sang_count(opt = {})
    limit = opt[:limit] || 20
    db = DB.new(
      :SELECT => {
        'song.id' => 'song_id' ,
        'song.name' => 'song_name' ,
        'song.artist' => 'artist_id' ,
        'song.url' => 'song_url' ,
        'artist.name' => 'artist_name' ,
        'count(*)' => 'count'
      } ,
      :FROM => 'history' ,
      :JOIN => [
        ['history' , 'song'] ,
        ['song' , 'artist']
      ] ,
      :OPTION => ['GROUP BY history.song' , 'ORDER BY count DESC' , "LIMIT #{limit}"] ,
    )
    # ユーザ指定がある場合、そのユーザのみを対象に
    if user = opt[:user]
      attends = user.attend_ids
      db.where_in(['history.attendance' , attends.length])
      db.set(attends)
    end
    db.execute_all
  end

  # artist_sang_count - クラスメソッド: 歌手の歌唱数ランキングを取得
  #--------------------------------------------------------------------
  def self.artist_sang_count(opt = {})
    limit = opt[:limit] || 20
    db = DB.new(
      :SELECT => {
        'artist.id' => 'artist_id' ,
        'artist.name' => 'artist_name' ,
        'count(*)' => 'count'
      } ,
      :FROM => 'history' ,
      :JOIN => [
        ['history' , 'song'] ,
        ['song' , 'artist'] ,
      ] ,
      :OPTION => ['GROUP BY artist.id' , 'ORDER BY count DESC' , "LIMIT #{limit}"]
    )
    # ユーザ指定がある場合、そのユーザのみを対象に
    if user = opt[:user]
      attends = user.attend_ids
      db.where_in(['history.attendance' , attends.length])
      db.set(attends)
    end
    db.execute_all
  end
end
