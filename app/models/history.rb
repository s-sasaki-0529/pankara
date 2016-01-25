#----------------------------------------------------------------------
# History - 個々の歌唱履歴に関する情報を操作
#----------------------------------------------------------------------
require_relative 'util'
class History < Base

	# initialize - インスタンスを生成
	#---------------------------------------------------------------------
	def initialize(id)

	end

	# song_ranking - クラスメソッド: 楽曲の歌唱数ランキングを取得
	#---------------------------------------------------------------------
	def self.song_ranking(limit)
		db = DB.new(
			:SELECT => {
				'song.id' => 'song_id' ,
				'song.name' => 'song_name' ,
				'song.artist' => 'artist_id' ,
				'song.url' => 'song_url' ,
				'artist.name' => 'artist_name' ,
				'count(*)' => 'count'
			} ,
			:FROM => 'history' ,
			:OPTION => "GROUP BY history.song ORDER BY count DESC LIMIT #{limit}"
		)
		db.join(
			['history' , 'song'] ,
			['song' , 'artist']
		)
		db.option('GROUP BY history.song' , 'ORDER BY count DESC' , "LIMIT #{limit}")
		db.execute_all
	end
end
