#----------------------------------------------------------------------
# Artist - 個々の歌手に関する情報を管理
#----------------------------------------------------------------------
require_relative 'db'
require_relative 'song'
class Artist

	attr_reader :params

	# initialize - インスタンスを生成
	#---------------------------------------------------------------------
	def initialize(id)
		@params = DB.new.get('artist' , id)
	end

	# songs - 楽曲一覧を取得
	#---------------------------------------------------------------------
	def songs
		db = DB.new
		db.select({
			'song.id' => 'song_id' ,
			'song.name' => 'song_name'
		})
		db.from('song')
		db.join(['song' , 'artist'])
		db.where('song.artist = ?')
		db.set(@params['id'])
		@params['songs'] = db.execute_all
	end

	# songs_with_ranking - 楽曲の一覧と歌唱回数を取得
	#---------------------------------------------------------------------
	def songs_with_ranking(userid)
		db = DB.new
		db.select('id')
		db.from('song')
		db.where('artist = ?')
		db.set(@params['id'])
		id_list = db.execute_columns

		songs = []
		id_list.each do |id|
			song = Song.new(id)
			song.count_all
			song.params['my_sangecount'] = song.count_as(userid)
			songs.push song
		end
		@params['songs'] = songs
	end
end
