#----------------------------------------------------------------------
# History - 個々の歌唱履歴に関する情報を操作
#----------------------------------------------------------------------
require_relative 'base'
require_relative 'util'
require_relative 'db'
require_relative 'song'
require_relative 'register'

class History < Base

  # initialize - historyを取得
  #--------------------------------------------------------------------
  def initialize(id , withInfo = false)
    @params = DB.new.get('history' , id)
    if withInfo
      songInfo = Song.new(@params['song']).params
      @params['song_name'] = songInfo['name']
      @params['artist_name'] = songInfo['artist_name']
      @params['url'] = songInfo['url']
    end
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

    if arg['url']
      song = Song.new(song_id)
      result = song.modify(arg)
      unless result
        return nil
      end
    end

    arg.select! do |k , v|
      ['attendance' , 'song' , 'songkey' , 'score_type' , 'score'].include?(k)
    end

    DB.new(
      :UPDATE => ['history' , arg.keys] ,
      :WHERE => 'id = ?' ,
      :SET => arg.values.push(@params['id'])
    ).execute
    old_params = @params
    @params = DB.new.get('history' , old_params['id'])
    Util.write_log('event' , "【歌唱履歴修正】#{old_params} → #{@params}")
  end

  # delete - カラオケレコードを削除する
  #--------------------------------------------------------------------
  def delete()
    song = Song.new(@params['song'])
    DB.new(:DELETE => 1 , :FROM => 'history' , :WHERE => 'id = ?' , :SET => @params['id']).execute
    Util.write_log('event' , "【歌唱履歴削除】#{@params} / #{song.params}")
    @params = nil
  end

  # recent_song - 最近歌われた楽曲のリストを戻す
  #---------------------------------------------------------------------
  def self.recent_song(limit = 20)
    # 最近20件のhistoryを取得
    # その楽曲名、歌手名、URLを取得

    songs = DB.new(
      :DISTINCT => true ,
      :SELECT => 'song' ,
      :FROM => 'history' ,
      :OPTION => ['ORDER BY history.id DESC' , "LIMIT #{limit}"]
    ).execute_columns
    songs.empty? and return []

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
    ).execute_all #現在はURLがyoutubeであることが前提。今後はプレーヤー化できるかの情報も必要になる
    songs_info.empty? and return []

    # 重複を排除した結果limitを下回った場合、limistになるまで同じデータを繰り返す
    while songs_info.length < limit
      songs_info = (songs_info + songs_info).each_slice(limit).to_a[0]
    end
    return songs_info
  end

end
