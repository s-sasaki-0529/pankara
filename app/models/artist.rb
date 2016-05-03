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
  def songs(opt = {})
    @params['songs'] = DB.new(
      :SELECT => {'song.id' => 'song_id' , 'song.name' => 'song_name' , 'song.url' => 'song_url'} ,
      :FROM => 'song' ,
      :WHERE => 'song.artist = ?' ,
      :SET => @params['id'] ,
    ).execute_all
  end

  # songs_with_count - 楽曲の一覧と歌唱回数を取得
  #---------------------------------------------------------------------
  def songs_with_count(userid = nil)

    @params['songs'] or self.songs
    song_ids = @params['songs'].map { |s| s['song_id'] }

    # 全体の歌唱回数集計
    db = DB.new(
      :SELECT => {'song' => 'song_id', 'COUNT(song)' => 'count'},
      :FROM => 'history',
      :WHERE_IN => ['song' , song_ids.length],
      :SET => song_ids,
      :OPTION => ['GROUP BY song' , 'ORDER BY count DESC']
    )
    db.execute_all
    sang_counts = Util.array_to_hash(db.execute_all , 'song_id')
    @params['songs'].each do |s|
      id = s['song_id']
      s['sang_count'] = sang_counts[id] ? sang_counts[id]['count'] : 0
    end

    # 指定ユーザの歌唱回数集計
    if userid
      user = User.new(:id => userid)
      attend_ids = user.attend_ids
      db.where_in(['attendance' , attend_ids.length])
      db.set(attend_ids)
      sang_counts_as_user = Util.array_to_hash(db.execute_all , 'song_id')
      @params['songs'].each do |s|
        id = s['song_id']
        s['sang_count_as_user'] = sang_counts_as_user[id] ? sang_counts_as_user[id]['count'] : 0
        s['sang_count'] -= s['sang_count_as_user']  #全体の歌った回数から自身の歌った回数を引く
      end
    end

  end

  # download_image - 歌手の画像を検索し、ローカルに保存する
  #--------------------------------------------------------------------
  def download_image
    url = Util.search_image(@params['name'] , {:thumbnail => 1})
    path = "app/public/image/artists/#{@params['id']}.png" #強制png
    system "wget '#{url}' -O '#{path}'"
  end

  # self.list - 歌手の一覧を取得
  #--------------------------------------------------------------------
  def self.list(opt = {})
    db = DB.new(:FROM => 'artist')

    # 曲名で曖昧検索
    if opt[:name_like]
      db.where('artist.name like ?')
      db.set("%#{opt[:name_like]}%")
    end

    # 楽曲登録数を取得
    if opt[:song_num]
      db.select(
        'COUNT(song.id)' => 'song_num',
        'artist.id' => 'id',
        'artist.name' => 'name',)
      db.flexible_join({:target => 'song' , :from => 'song' , :to => 'artist'})
      db.option(['GROUP BY song.artist' , 'ORDER BY song_num DESC'])
    end

    db.execute_all
  end
end
