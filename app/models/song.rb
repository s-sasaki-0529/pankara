#----------------------------------------------------------------------
# Song - 個々の楽曲に関する情報を操作
#----------------------------------------------------------------------
require_relative 'db'
class Song

	attr_reader :params

	# initialize - インスタンスを生成し、曲名、歌手名を取得する
	#---------------------------------------------------------------------
	def initialize(id)
		@params = DB.sql_row("SELECT id , artist , name FROM song WHERE id = ?" , [id])
		@params['artist_name'] = DB.sql_row("
			SELECT artist.name
			FROM artist join song ON artist.id = song.artist
			WHERE song.id = ?" , [id]
		)['name']
	end

end
