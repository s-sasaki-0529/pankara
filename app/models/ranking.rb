#----------------------------------------------------------------------
# Ranking - 各種ランキングを生成するクラス
#----------------------------------------------------------------------
require_relative 'util'
class Ranking < Base

	# sang_count - クラスメソッド: 楽曲の歌唱数ランキングを取得
	#---------------------------------------------------------------------
	def self.sang_count(limit = 20)
		DB.new(
			:SELECT => {
				'song.id' => 'song_id' ,
				'song.name' => 'song_name' ,
				'song.artist' => 'artist_id' ,
				'song.url' => 'song_url' ,
				'artist.name' => 'artist_name' ,
				'count(*)' => 'count'
			} ,
			:FROM => 'history' ,
			:JOIN => [
				['history' , 'song'] ,
				['song' , 'artist']
			] ,
			:OPTION => ['GROUP BY history.song' , 'ORDER BY count DESC' , "LIMIT #{limit}"] ,
		).execute_all
	end
end
