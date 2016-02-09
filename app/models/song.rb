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

	# sangcount - 歌唱回数を取得
	# userの指定がない場合、全体を対象とする
	#---------------------------------------------------------------------
	def sangcount(userid = nil)
		db = DB.new(:SELECT => {'COUNT(*)' => 'count'} , :FROM => 'history')
		if userid
			db.join(['history' , 'attendance'])
			db.where(['attendance.user = ?' , 'history.song = ?'])
			db.set([userid , @params['id']])
			db.option(['GROUP BY history.song' , 'ORDER BY count DESC'])
		else
			db.where('song = ?')
			db.set(@params['id'])
		end

		count = db.execute_column
		return (count.nil?) ? 0 : count
	end

	# tally_score - 得点の集計を得る
	# useridの指定がない場合、全体を対象とする
	#---------------------------------------------------------------------
	def tally_score(score_type , userid = nil)
		db = DB.new(
			:SELECT => {
				'MAX(score)' => 'score_max' ,
				'MIN(score)' => 'score_min' ,
				'AVG(score)' => 'score_avg' ,
			} ,
			:FROM => 'history'
		)
		where = ['song = ?' , 'score_type = ?']
		set = [@params['id'] , score_type]

		if userid
			db.join(['history' , 'attendance'])
			where.push 'attendance.id = ?'
			set.push userid
		end
		db.where(where)
		db.set(set)
		db.execute_row
	end

	# history_list - この曲の歌唱履歴を取得
	# useridを省略した場合、全ユーザを対象にする
	#---------------------------------------------------------------------
	def history_list(limit , userid = nil)
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
			:JOIN => [
				['history' , 'attendance'] ,
				['attendance' , 'karaoke'] ,
				['attendance' , 'user'] ,
			],
			:FROM => 'history' ,
			:OPTION => ['ORDER BY karaoke.datetime DESC' , 'LIMIT 10'] ,
		)
		where = ['history.song = ?']
		set = [@params['id']]

		if userid
			where.push 'attendance.user = ?'
			set.push userid
		end
		db.where(where)
		db.set(set)

		result = db.execute_all
		result.each do |sang|
			sang['scoretype_name'] = ScoreType.id_to_name(sang['score_type'] , true).values.join("<br>")
		end
		return result
	end

end
