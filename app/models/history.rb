#----------------------------------------------------------------------
# History - 個々の歌唱履歴に関する情報を操作
#----------------------------------------------------------------------
require_relative 'db'
class History

	attr_reader :params

	# initialize - インスタンスを生成
	#---------------------------------------------------------------------
	def initialize(id)

	end

	# song_ranking - クラスメソッド: 楽曲の歌唱数ランキングを取得
	#---------------------------------------------------------------------
	def self.song_ranking
		DB.sql_all(
			"SELECT song.id as song_id , artist.name as artist_name , song.name as song_name ,
							count(*) as count
			FROM (history JOIN song ON history.song = song.id) JOIN artist ON song.artist = artist.id
			GROUP BY history.song ORDER BY count DESC;"
		)
	end
end
