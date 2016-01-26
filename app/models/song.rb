#----------------------------------------------------------------------
# Song - 個々の楽曲に関する情報を操作
#----------------------------------------------------------------------
require_relative 'util'
class Song < Base

	# initialize - インスタンスを生成し、曲名、歌手名を取得する
	#---------------------------------------------------------------------
	def initialize(id)
		@params = DB.new.get('song' , id)
		self.song_name
	end

	# artist_name - 歌手名を取得
	#---------------------------------------------------------------------
	def song_name
		@params['artist_name'] = DB.new(
			:SELECT => {'artist.name' => 'artist_name'} ,
			:FROM => 'song' ,
			:JOIN => ['song' , 'artist'] ,
			:WHERE => 'song.id = ?' ,
			:SET => @params['id']
		).execute_column
	end

	# count_all - 全歌唱回数を取得
	#---------------------------------------------------------------------
	def count_all
		count = DB.new(
			:SELECT => {'COUNT(*)' => 'count'} ,
			:FROM => 'history' ,
			:WHERE => 'song = ?' ,
			:SET => @params['id'] ,
		).execute_column
		@params['sangcount'] = (count.nil?) ? 0 : count
	end

	# count_as - 対象ユーザの歌唱回数を取得
	#---------------------------------------------------------------------
	def count_as(userid)
		count = DB.new(
			:SELECT => {'COUNT(*)' => 'count'} ,
			:FROM => 'history' ,
			:JOIN => ['history' , 'attendance'] ,
			:WHERE => ['attendance.user = ?' , 'history.song = ?'] ,
			:SET => [userid , @params['id']] ,
			:OPTION => ['GROUP BY history.song' , 'ORDER BY count DESC'] ,
		).execute_column
		return (count.nil?) ? 0 : count
	end

	# score_all - 全ユーザの採点結果を取得、集計する
	#---------------------------------------------------------------------
	def score_all(score_type)
		result = DB.new(
			:SELECT => {
				'MAX(score)' => 'score_max' ,
				'MIN(score)' => 'score_min' ,
				'AVG(score)' => 'score_avg'
			} ,
			:FROM => 'history' ,
			:WHERE => ['song = ?' , 'score_type = ?'] ,
			:SET => [@params['id'] , score_type] ,
		).execute_row
		@params.merge! result
	end

	# score_all - 対象ユーザの採点結果を取得、集計する
	#---------------------------------------------------------------------
	def score_as(score_type , userid)
		result = DB.new(
			:SELECT => {
				'MAX(score)' => 'score_max' ,
				'MIN(score)' => 'score_min' ,
				'AVG(score)' => 'score_avg'
			} ,
			:FROM => 'history' ,
			:JOIN => ['history' , 'attendance'] ,
			:WHERE => ['song = ?' , 'score_type = ?' , 'user = ?'] ,
			:SET => [@params['id'] , score_type , userid] ,
		).execute_row
		return result
	end

	# sang_history_all - 全ユーザのこの曲の歌唱履歴を取得(最近１０件)
	#---------------------------------------------------------------------
	def sang_history_all
		db = DB.new(
			:SELECT => {
				'karaoke.id' => 'karaoke_id' ,
				'karaoke.name' => 'karaoke_name' ,
				'karaoke.datetime' => 'datetime' ,
				'user.username' => 'username' ,
				'user.screenname' => 'user_screenname' ,
				'history.songkey' => 'songkey' ,
				'history.score_type' => 'score_type' ,
				'history.score' => 'score'
			} ,
			:FROM => 'history' ,
			:JOIN => [
				['history' , 'attendance'] ,
				['attendance' , 'karaoke'] ,
				['attendance' , 'user'] ,
			] ,
			:WHERE => 'history.song = ?' ,
			:SET => @params['id'] ,
			:OPTION => ['ORDER BY karaoke.datetime DESC' , 'LIMIT 10'] ,
		)
		@params['sang_history'] = db.execute_all
		@params['sang_history'].each do |sang|
			sang['scoretype_name'] = ScoreType.id_to_name(sang['score_type'])
		end
	end

	# sang_history_as - 対象ユーザの採点結果を取得、集計する
	#---------------------------------------------------------------------
	def sang_history_as(userid)
		db = DB.new(
			:SELECT => {
				'karaoke.id' => 'karaoke_id' ,
				'karaoke.name' => 'karaoke_name' ,
				'karaoke.datetime' => 'datetime' ,
				'user.username' => 'username' ,
				'user.screenname' => 'user_screenname' ,
				'history.songkey' => 'songkey' ,
				'history.score_type' => 'score_type' ,
				'history.score' => 'score'
			} ,
			:FROM => 'history' ,
			:JOIN => [
				['history' , 'attendance'] ,
				['attendance' , 'user'] ,
				['attendance' , 'karaoke'] ,
			] ,
			:WHERE => ['history.song = ?' , 'attendance.user = ?'] ,
			:SET => [@params['id'] , userid] ,
			:OPTION => ['ORDER BY karaoke.datetime DESC' , 'LIMIT 10'],
		)
		result = db.execute_all
		result.each do |sang|
			sang['scoretype_name'] = ScoreType.id_to_name(sang['score_type'])
		end
		return result
	end

end
