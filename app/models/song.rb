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

	# count_all - 全歌唱回数を取得
	#---------------------------------------------------------------------
	def count_all
		count = DB.sql_column("
			SELECT COUNT(*) as count FROM history WHERE song = ?" , [@params['id']]
		)
		@params['sangcount'] = (count.nil?) ? 0 : count
	end

	# count_as - 対象ユーザの歌唱回数を取得
	#---------------------------------------------------------------------
	def count_as(userid)
		count = DB.sql_column("
			SELECT COUNT(*) AS count from history
			JOIN attendance ON history.attendance = attendance.id
			WHERE attendance.user = ? and history.song = ?
			GROUP BY history.song ORDER BY count DESC;" , [userid , @params['id']]
		)
		return (count.nil?) ? 0 : count
	end

	# score_all - 全ユーザの採点結果を取得、集計する
	#---------------------------------------------------------------------
	def score_all(score_type)
		result = DB.sql_row("
			select MAX(score) as score_max , MIN(score) as score_min , AVG(score) as score_avg
			from history where song = ? and score_type = ?" , [@params['id'] , score_type]
		)
		result.each do |key , value|
			result[key] = sprintf "%.2f" , value.to_f
		end
		@params.merge! result
	end

	# score_all - 対象ユーザの採点結果を取得、集計する
	#---------------------------------------------------------------------
	def score_as(score_type , userid)
	end

end
