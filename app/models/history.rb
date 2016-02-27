#----------------------------------------------------------------------
# History - 個々の歌唱履歴に関する情報を操作
#----------------------------------------------------------------------
require_relative 'util'
class History < Base

  # initialize - historyを取得
  #--------------------------------------------------------------------
  def initialize(id)
    @params = DB.new.get('history' , id)
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

    arg.select! do |k , v|
      ['attendance' , 'song' , 'songkey' , 'score_type' , 'score'].include?(k)
    end
    DB.new(
      :UPDATE => ['history' , arg.keys] ,
      :WHERE => 'id = ?' ,
      :SET => arg.values.push(@params['id'])
    ).execute
    @params = DB.new.get('history' , @params['id'])
  end

  # delete - カラオケレコードを削除する
  #--------------------------------------------------------------------
  def delete()
    DB.new(:DELETE => 1 , :FROM => 'history' , :WHERE => 'id = ?' , :SET => @params['id']).execute
    @params = nil
  end

  # recent_song - 最近歌われた楽曲のリストを戻す
  #---------------------------------------------------------------------
  def self.recent_song(limit = 20)
    songs = DB.new(
      :DISTINCT => true ,
      :SELECT => {
          'song.id' => 'id' ,
          'song.name' => 'name' ,
          'song.url' => 'url'
      } ,
      :FROM => 'history' ,
      :JOIN => ['history' , 'song'] ,
      :WHERE => 'song.url IS NOT NULL' ,
      :OPTION => ['ORDER BY history.created_at DESC' , "LIMIT #{limit}"]
    ).execute_all #現在はURLがyoutubeであることが前提。今後はプレーヤー化できるかの情報も必要になる
    songs.empty? and return []

    while songs.length < limit
      songs = (songs + songs).each_slice(limit).to_a[0]
    end
    return songs
  end

end
