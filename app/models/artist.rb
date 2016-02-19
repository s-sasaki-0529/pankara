#----------------------------------------------------------------------
# Artist - 個々の歌手に関する情報を管理
#----------------------------------------------------------------------
require_relative 'util'
class Artist < Base

  # initialize - インスタンスを生成
  #---------------------------------------------------------------------
  def initialize(id)
    @params = DB.new.get('artist' , id)
  end

  # songs - 楽曲一覧を取得
  #---------------------------------------------------------------------
  def songs
    @params['songs'] = DB.new(
      :SELECT => {'song.id' => 'song_id' , 'song.name' => 'song_name'} ,
      :FROM => 'song' ,
      :WHERE => 'song.artist = ?' ,
      :SET => @params['id'] ,
    ).execute_all
  end

  # songs_with_count - 楽曲の一覧と歌唱回数を取得
  #---------------------------------------------------------------------
  def songs_with_count(userid)
    db = DB.new(:SELECT => 'id' , :FROM => 'song' , :WHERE => 'artist = ?' , :SET => @params['id'])
    id_list = db.execute_columns
    songs = []
    id_list.each do |id|
      song = Song.new(id)
      song.params['sangcount'] = song.sangcount()
      song.params['my_sangcount'] = song.sangcount(userid)
      songs.push song
    end
    @params['songs'] = songs
  end
end
