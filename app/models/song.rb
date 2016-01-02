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
		db = DB.new
		db.select('artist.name' => 'artist_name')
		db.from('song')
		db.join(['song' , 'artist'])
		db.where('song.id = ?')
		db.set(@params['id'])
		@params['artist_name'] = db.execute_column
	end

	# count_all - 全歌唱回数を取得
	#---------------------------------------------------------------------
	def count_all
		db = DB.new
		db.select({'COUNT(*)' => 'count'})
		db.from('history')
		db.where('song = ?')
		db.set(@params['id'])
		count = db.execute_column
		@params['sangcount'] = (count.nil?) ? 0 : count
	end

	# count_as - 対象ユーザの歌唱回数を取得
	#---------------------------------------------------------------------
	def count_as(userid)
		db = DB.new
		db.select({'COUNT(*)' => 'count'})
		db.from('history')
		db.join(['history' , 'attendance'])
		db.where('attendance.user = ?' , 'history.song = ?')
		db.option('GROUP BY history.song ORDER BY count DESC')
		db.set(userid , @params['id'])
		count = db.execute_column
		return (count.nil?) ? 0 : count
	end

	# score_all - 全ユーザの採点結果を取得、集計する
	#---------------------------------------------------------------------
	def score_all(score_type)
		db = DB.new
		db.select({
			'MAX(score)' => 'score_max' ,
			'MIN(score)' => 'score_min' ,
			'AVG(score)' => 'score_avg'
		})
		db.from('history')
		db.where('song = ?' , 'score_type = ?')
		db.set(@params['id'] , score_type)
		result = db.execute_row
		transcate_score(result)
		@params.merge! result
	end

	# score_all - 対象ユーザの採点結果を取得、集計する
	#---------------------------------------------------------------------
	def score_as(score_type , userid)
		db = DB.new
		db.select({
			'MAX(score)' => 'score_max' ,
			'MIN(score)' => 'score_min' ,
			'AVG(score)' => 'score_avg'
		})
		db.from('history')
		db.join(['history' , 'attendance'])
		db.where('song = ?' , 'score_type = ?' , 'user = ?')
		db.set(@params['id'] , score_type , userid)
		result = db.execute_row
		transcate_score(result)
		return result
	end

	# sang_history_all - 全ユーザのこの曲の歌唱履歴を取得(最近１０件)
	#---------------------------------------------------------------------
	def sang_history_all
		db = DB.new
		db.select({
			'karaoke.datetime' => 'datetime' ,
			'user.id' => 'user_id' ,
			'user.screenname' => 'user_screenname' ,
			'history.songkey' => 'songkey' ,
			'history.score_type' => 'score_type' ,
			'history.score' => 'score'
		})
		db.from('history')
		db.join(
			['history' , 'attendance'] ,
			['attendance' , 'user'] ,
			['attendance' , 'karaoke']
		)
		db.where('history.song = ?')
		db.option('ORDER BY karaoke.datetime DESC LIMIT 10')
		db.set(@params['id'])
		@params['sang_history'] = db.execute_all
		@params['sang_history'].each do |sang|
			sang['score'] = sprintf "%.2f" , sang['score']
		end
	end

	# sang_history_as - 対象ユーザの採点結果を取得、集計する
	#---------------------------------------------------------------------
	def sang_history_as(userid)
		db = DB.new
		db.select({
			'karaoke.datetime' => 'datetime' ,
			'user.id' => 'user_id' ,
			'user.screenname' => 'user_screenname' ,
			'history.songkey' => 'songkey' ,
			'history.score_type' => 'score_type' ,
			'history.score' => 'score'
		})
		db.from('history')
		db.join(
			['history' , 'attendance'] ,
			['attendance' , 'user'] ,
			['attendance' , 'karaoke']
		)
		db.where('history.song = ?' , 'attendance.user = ?')
		db.option('ORDER BY karaoke.datetime DESC LIMIT 10')
		db.set(@params['id'] , userid)
		result = db.execute_all
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
