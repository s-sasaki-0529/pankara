#----------------------------------------------------------------------
# 不要なデータを自動削除するスクリプト
# 本スクリプトは、cronによって定期自動実行されることを想定
#----------------------------------------------------------------------
require_relative "../../app/models/util"
require_relative "../../app/models/song"
require_relative "../../app/models/artist"
require_relative "../../app/models/store"
require_relative "../../app/models/karaoke"

# 一度も歌われていなく、登録から１週間が経過したタグのない楽曲を削除
songs = DB.new(:SELECT => 'id' , :FROM => 'song' , :WHERE => 'DATE_ADD(created_at, INTERVAL 7 DAY) < NOW()').execute_columns
history = DB.new(:SELECT => 'song' , :FROM => 'history').execute_columns.uniq
no_sang_songs = songs - history
no_sang_songs.each do |id|
  song = Song.new(id)
  tags = song.tags
  if tags.empty?
    puts "楽曲削除 #{song['name']} (#{song['artist_name']})"
    DB.new(:DELETE => 1 , :FROM => 'song' , :WHERE => 'id = ?' , :SET => song['id']).execute
  end
end

# 一曲も楽曲が無いアーティストを削除
artists = DB.new(:SELECT => 'id' , :FROM => 'artist').execute_columns
sang_artists = DB.new(:SELECT => 'artist' , :FROM => 'song').execute_columns.uniq
trash_artists = artists - sang_artists
trash_artists.each do |id|
  artist = Artist.new(id)
  puts "歌手削除 #{artist['name']}"
end
trash_artists.empty? or DB.new(:DELETE => 1 , :FROM => 'artist' , :WHERE_IN => ['id' , trash_artists.length] , :SET => trash_artists).execute

# 一度も利用されていない店舗を削除
stores = DB.new(:SELECT => 'id' , :FROM => 'store').execute_columns
used_stores = DB.new(:SELECT => 'store' , :FROM => 'karaoke').execute_columns.uniq
trash_stores = stores - used_stores
trash_stores.each do |id|
  store = Store.new(id)
  puts "店舗削除 #{store['name']}(#{store['branch']})"
end
trash_stores.empty? or DB.new(:DELETE => 1 , :FROM => 'store' , :WHERE_IN => ["id" , trash_stores.length], :SET => trash_stores).execute

# 登録から４８時間経過後も歌唱履歴が登録されていないカラオケを削除
karaoke_list = DB.new(:SELECT => ['id' , 'name'] , :FROM => 'karaoke' , :WHERE => 'DATE_ADD(created_at, INTERVAL 48 HOUR) < NOW()').execute_all
karaoke_list.each do |karaoke|
  attend_list = DB.new(:SELECT => 'id' , :FROM => 'attendance' , :WHERE => 'karaoke = ?' , :SET => karaoke['id']).execute_columns
  if attend_list.empty?
    puts "カラオケ削除 #{karaoke['name']}"
    Karaoke.new(karaoke['id']).delete
  else
    histories = DB.new(:SELECT => 'id' , :FROM => 'history' , :WHERE_IN => ['attendance' , attend_list.length] , :SET => attend_list).execute_all
    if histories.empty?
      puts "カラオケ削除 #{karaoke['name']}"
      Karaoke.new(karaoke['id']).delete
    end
  end
end

