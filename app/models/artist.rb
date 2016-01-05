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

	# songs_with_ranking
	#---------------------------------------------------------------------
	def songs_with_ranking
		db = DB.new
		db.select({
			'song.id' => 'song_id' ,
			'song.name' => 'song_name' ,
			'count(*)' => 'count'
		})
		db.from('history')
		db.join(
			['history' , 'song'] ,
			['song' , 'artist']
		)
		db.where('song.artist = ?')
		db.set(@params['id'])
		db.option('GROUP BY history.song' , 'ORDER BY count DESC')
		@params['songs'] = db.execute_all
	end
end
