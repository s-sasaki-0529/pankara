#----------------------------------------------------------------------
# Ranking - 各種ランキングを生成するクラス
#----------------------------------------------------------------------
require_relative 'base'
require_relative 'util'
require_relative 'user'
require_relative 'song'
require_relative 'db'
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
    songs_info = Song.list(:songs => songs.uniq, :artist_info => true, :want_hash => true)

    #各種情報をランキングにマージ
    ranking.each do |row|
      row.merge! users_info[row['user']]
      row.merge! songs_info[row['song']]
    end
    return ranking
  end

  # sang_count - クラスメソッド: 楽曲の歌唱数ランキングを取得
  # opt[:limit] - 取得件数を指定
  # opt[:user] - 対象ユーザを指定。idでなくUserインスタンス
  #--------------------------------------------------------------------
  def self.sang_count(opt = {})
    limit = opt[:limit] || 20

    # 歌唱履歴より、song列ごとの件数上位limitレコードを取得
    #db = DB.new(
    #  :SELECT => {'song' => 'song_id' , 'COUNT(song)' => 'count'},
    #  :FROM => 'history',
    #  :OPTION => ['GROUP BY song' , 'ORDER BY count DESC' , "LIMIT #{limit}"]
    #)

    # 歌唱履歴をまとめて取得
    db = DB.new(:SELECT => ['song' , 'attendance'], :FROM => 'history')

    # ユーザ指定がある場合、そのユーザの歌唱回数のみで集計
    if user = opt[:user]
      attend_ids = user.attend_ids
      db.where_in(['attendance' , attend_ids.length])
      db.set(attend_ids)
    end
    songs = db.execute_all

    # 楽曲IDのみ抜き出す
    opt[:disdinct] and ranking.uniq!
    songs = songs.map {|r| r['song']}

    # ランキングの生成
    ranking = Ranking.create_from_array(songs , limit)

    # 楽曲、アーティストの情報を付与
    songs_ids = ranking.map {|s| s['value']}
    songs_info = Song.list(:songs => songs_ids, :artist_info => true, :want_hash => true)
    ranking.each do |r|
      r.merge!(songs_info[r['value']])
    end
    return ranking
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

  # create_from_array - クラスメソッド: 配列を対象にランキングを生成する
  #--------------------------------------------------------------------
  def self.create_from_array(array , limit = nil)
    # 値ごとの出現回数を数える
    counts = array.inject(Hash.new(0)) {|hash , v| hash[v] += 1; hash}
    # 回数が多い順に並び替え
    counts = counts.sort {|(k1 , v1) , (k2 , v2)| v2 <=> v1}
    limit and counts = counts.first(limit)
    # ハッシュ配列に変換し、連番を振って戻す
    ranking = []
    counts.each_with_index do |v , idx|
      ranking.push({
        'rank' => idx + 1 ,
        'value' => v[0] ,
        'count' => v[1]
      })
    end
    return ranking
  end

  # create_from_hash - クラスメソッド: ハッシュを対象にランキングを生成する
  #--------------------------------------------------------------------
  def self.create_from_hash(hash , key)
  end
end
