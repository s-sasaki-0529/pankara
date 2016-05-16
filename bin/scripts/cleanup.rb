require_relative "../../app/models/util"
require_relative "../../app/models/song"
require_relative "../../app/models/artist"
require_relative "../../app/models/store"

# song
songs = DB.new(:SELECT => 'id' , :FROM => 'song').execute_columns
history = DB.new(:SELECT => 'song' , :FROM => 'history').execute_columns.uniq
trash_songs = songs - history
qlist = Util.make_questions(trash_songs.length)
trash_songs.each do |id|
  song = Song.new(id)
  puts "楽曲削除 #{song['name']} (#{song['artist_name']})"
end
trash_songs.empty? or DB.new(:DELETE => 1 , :FROM => 'song' , :WHERE => "id in (#{qlist})" , :SET => trash_songs).execute

# artist
artists = DB.new(:SELECT => 'id' , :FROM => 'artist').execute_columns
sang_artists = DB.new(:SELECT => 'artist' , :FROM => 'song').execute_columns.uniq
trash_artists = artists - sang_artists
qlist = Util.make_questions(trash_artists.length)
trash_artists.each do |id|
  artist = Artist.new(id)
  puts "歌手削除 #{artist['name']}"
end
trash_artists.empty? or DB.new(:DELETE => 1 , :FROM => 'artist' , :WHERE => "id in (#{qlist})" , :SET => trash_artists).execute

# store
stores = DB.new(:SELECT => 'id' , :FROM => 'store').execute_columns
used_stores = DB.new(:SELECT => 'store' , :FROM => 'karaoke').execute_columns.uniq
trash_stores = stores - used_stores
trash_stores.each do |id|
  store = Store.new(id)
  puts "店舗削除 #{store['name']}(#{store['branch']})"
end
trash_stores.empty? or DB.new(:DELETE => 1 , :FROM => 'store' , :WHERE => "id in (#{qlist})" , :SET => trash_stores).execute
