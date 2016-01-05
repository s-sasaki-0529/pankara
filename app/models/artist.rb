#----------------------------------------------------------------------
# Artist - 個々の歌手に関する情報を管理
#----------------------------------------------------------------------
require_relative 'db'
class Artist

	attr_reader :params

	# initialize - インスタンスを生成
	#---------------------------------------------------------------------
	def initialize(id)
		@params = DB.new.get('artist' , id)
	end

	# songs - 楽曲一覧を歌唱回数とともに取得
	#---------------------------------------------------------------------
	def get_songs
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
end
