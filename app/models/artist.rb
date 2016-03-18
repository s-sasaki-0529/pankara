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
  def songs_with_count(userid = nil)
    db = DB.new(:SELECT => 'id' , :FROM => 'song' , :WHERE => 'artist = ?' , :SET => @params['id'])
    id_list = db.execute_columns
    songs = []
    id_list.each do |id|
      song = Song.new(id)
      song.params['sangcount'] = song.sangcount({:without_user => userid})
      userid and song.params['my_sangcount'] = song.sangcount({:target_user => userid})
      songs.push song
    end
    @params['songs'] = songs
  end

  # self.list - 歌手の一覧を取得
  #--------------------------------------------------------------------
  def self.list(opt = nil)
    db = DB.new(:FROM => 'artist')
    # 曲名で曖昧検索
    if opt[:name_like]
      db.where('artist.name like ?')
      db.set("%#{opt[:name_like]}%")
    end

    db.execute_all
  end
end
