#----------------------------------------------------------------------
# Song - 個々の楽曲に関する情報を操作
#----------------------------------------------------------------------
require_relative 'db'
class Song

	attr_reader :params

	# initialize - インスタンスを生成し、曲名、歌手名を取得する
	#---------------------------------------------------------------------
	def initialize(id)
		@params = DB.get('song' , id)
		self.song_name
	end

	# artist_name - 歌手名を取得
	#---------------------------------------------------------------------
	def song_name
		select = DB.select('artist.name' => 'artist_name')
		from = DB.from('song')
		join = DB.join(['song' , 'artist'])
		where = DB.where('song.id = ?')
		sql = [select , from , join , where].join(' ')
		@params['artist_name'] = DB.sql_column(sql , @params['id'])
	end

	# count_all - 全歌唱回数を取得
	#---------------------------------------------------------------------
	def count_all
		select = DB.select({'COUNT(*)' => 'count'})
		from = DB.from('history')
		where = DB.where('song = ?')
		sql = [select , from , where].join(' ')
		count = DB.sql_column(sql , [@params['id']])
		@params['sangcount'] = (count.nil?) ? 0 : count
	end

	# count_as - 対象ユーザの歌唱回数を取得
	#---------------------------------------------------------------------
	def count_as(userid)
		select = DB.select({'COUNT(*)' => 'count'})
		from = DB.from('history')
		join = DB.join(['history' , 'attendance'])
		where = DB.where('attendance.user = ?' , 'history.song = ?')
		option = 'GROUP BY history.song ORDER BY count DESC'
		sql = [select , from , join , where , option].join(' ')
		count = DB.sql_column(sql , [userid , @params['id']])
		return (count.nil?) ? 0 : count
	end

	# score_all - 全ユーザの採点結果を取得、集計する
	#---------------------------------------------------------------------
	def score_all(score_type)
		select = DB.select({
			'MAX(score)' => 'score_max' ,
			'MIN(score)' => 'score_min' ,
			'AVG(score)' => 'score_avg'
		})
		from = DB.from('history')
		where = DB.where('song = ?' , 'score_type = ?')
		sql = [select , from , where].join(' ')
		result = DB.sql_row(sql , [@params['id'] , score_type])
		transcate_score(result)
		@params.merge! result
	end

	# score_all - 対象ユーザの採点結果を取得、集計する
	#---------------------------------------------------------------------
	def score_as(score_type , userid)
		select = DB.select({
			'MAX(score)' => 'score_max' ,
			'MIN(score)' => 'score_min' ,
			'AVG(score)' => 'score_avg'
		})
		from = DB.from('history')
		join = DB.join(['history' , 'attendance'])
		where = DB.where('song = ?' , 'score_type = ?' , 'user = ?')
		sql = [select , from , join , where].join(' ')
		result = DB.sql_row(sql , [@params['id'] , score_type , userid])
		transcate_score(result)
		return result
	end

	# sang_history_all - 全ユーザのこの曲の歌唱履歴を取得(最近１０件)
	#---------------------------------------------------------------------
	def sang_history_all
		select = DB.select({
			'karaoke.datetime' => 'datetime' ,
			'user.id' => 'user_id' ,
			'user.screenname' => 'user_screenname' ,
			'history.songkey' => 'songkey' ,
			'history.score_type' => 'score_type' ,
			'history.score' => 'score'
		})
		from = DB.from('history')
		join = DB.join(
			['history' , 'attendance'] ,
			['attendance' , 'user'] ,
			['attendance' , 'karaoke']
		)
		where = DB.where('history.song = ?')
		option = 'ORDER BY karaoke.datetime DESC LIMIT 10'
		sql = [select , from , join , where , option].join(' ')

		@params['sang_history'] = DB.sql_all(sql , [@params['id']])
		@params['sang_history'].each do |sang|
			sang['score'] = sprintf "%.2f" , sang['score']
		end
	end

	# sang_history_as - 対象ユーザの採点結果を取得、集計する
	#---------------------------------------------------------------------
	def sang_history_as(userid)
		select = DB.select({
			'karaoke.datetime' => 'datetime' ,
			'user.id' => 'user_id' ,
			'user.screenname' => 'user_screenname' ,
			'history.songkey' => 'songkey' ,
			'history.score_type' => 'score_type' ,
			'history.score' => 'score'
		})
		from = DB.from('history')
		join = DB.join(
			['history' , 'attendance'] ,
			['attendance' , 'user'] ,
			['attendance' , 'karaoke']
		)
		where = DB.where('history.song = ?' , 'attendance.user = ?')
		option = 'ORDER BY karaoke.datetime DESC LIMIT 10'
		sql = [select , from , join , where].join(' ')

		result = DB.sql_all(sql , [@params['id'] , userid])
		result.each do |sang|
			sang['score'] = sprintf "%.2f" , sang['score']
		end
		return result
	end

	# transcate_score - (プライベートメソッド) 集計したスコアの桁数を合わせる
	#---------------------------------------------------------------------
	private
	def transcate_score(hash)
		hash.each do |key , value|
			hash[key] = sprintf "%.2f" , value.to_f
		end
	end
end
