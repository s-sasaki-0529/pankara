#----------------------------------------------------------------------
# User - 個々のユーザアカウントに関する情報を操作
#----------------------------------------------------------------------
require_relative 'util'
class User < Base

	# initialize(username:) - usernameを指定してインスタンスを生成
	#---------------------------------------------------------------------
	def initialize(username)
		@params = DB.new(:FROM => 'user' , :WHERE => 'username = ?' , :SET => username).execute_row
	end

	# histories - 歌唱履歴を取得、limitを指定するとその行数だけ取得
	#---------------------------------------------------------------------
	def histories(limit = 0)
		db = DB.new(
			:SELECT => {
				'karaoke.name' => 'karaoke_name' ,
				'karaoke.datetime' => 'datetime' ,
				'history.song' => 'song' ,
				'history.songkey' => 'songkey'
			} ,
			:FROM => 'history' ,
			:JOIN => [
				['history' , 'attendance'] ,
				['attendance' , 'karaoke']
			] ,
			:WHERE => 'attendance.user = ?' ,
			:SET => @params['id'] ,
			:OPTION => 'ORDER BY datetime DESC' ,
		)
		db.option("LIMIT #{limit}") if limit > 0
		histories = db.execute_all
		histories.each do | history |
			song = Song.new(history['song'])
			history['song_name'] = song.params['name']
			history['artist'] = song.params['artist']
			history['artist_name'] = song.params['artist_name']
		end
		return histories
	end

	# get_karaoke - limitを指定するとその行数だけ取得
	#---------------------------------------------------------------------
	def get_karaoke(limit = 0)
		# 対象ユーザが参加したkaraokeのID一覧を取得
		db = DB.new(
			:SELECT => 'karaoke' , :FROM => 'attendance' , :WHERE => 'user = ?' , :SET => @params['id'] , 
			:OPTION => (limit > 0) ? "LIMIT #{limit}" : nil
		)
		attended_id_list = db.execute_all.collect {|info| info['karaoke']}

		# 全karaokeの情報から、ユーザが参加したカラオケについてのみ抽出
		all_karaoke_info = Karaoke.list_all
		attended_karaoke_info = all_karaoke_info.select do |karaoke|
			attended_id_list.include?(karaoke['id'])
		end
		return attended_karaoke_info
	end

	# create_karaoke_log - karaokeレコードを挿入し、attendanceレコードを紐付ける
	#---------------------------------------------------------------------
	def create_karaoke_log(params)
		datetime = params[:datetime]
		plan = params[:plan].to_f
		store = params[:store].to_i
		product = params[:product].to_i

		karaoke_id = DB.new(
			:INSERT => ['karaoke' , ['datetime' , 'plan' , 'store' , 'product']] ,
			:SET => [datetime , plan , store , product]
		).execute_insert_id

		DB.new(
			:INSERT => ['attendance' , ['user' , 'karaoke']] ,
			:SET => [@params['id'] , karaoke_id] ,
		).execute_insert_id
	end

	# get_most_sang_song - 最も歌っている曲を取得する 
	#---------------------------------------------------------------------
	def get_most_sang_song
		@most_sang_song = DB.new(
			:SELECT => {'history.song' => 'song' , 'COUNT(*)' => 'counter'} ,
			:FROM => 'history' ,
			:JOIN => ['history' , 'attendance'] ,
			:WHERE => 'attendance.user = ?' ,
			:SET => @params['id'] ,
			:OPTION => ['GROUP BY song', 'ORDER BY counter DESC, history.created_at DESC']
		).execute_row

		get_song @most_sang_song
		return @most_sang_song
	end

	# get_most_sang_artist - 最も歌っている歌手を取得する 
	#---------------------------------------------------------------------
	def get_most_sang_artist
		@most_sang_artist = DB.new(
			:SELECT => {'song.artist' => 'artist', 'COUNT(*)' => 'counter'} ,
			:FROM => 'history' ,
			:JOIN => [
				['history' , 'attendance'] ,
				['history' , 'song'] ,
			] ,
			:WHERE => 'attendance.user = ?' ,
			:SET => @params['id'] ,
			:OPTION => ['GROUP BY artist', 'ORDER BY counter DESC, history.created_at DESC'] ,
		).execute_row

		@most_sang_artist['artist_name'] = DB.new(
			:SELECT => 'name' , :FROM => 'artist' , :WHERE => 'id = ?' , :SET => @most_sang_artist['artist']
		).execute_column
		return @most_sang_artist
	end

	# get_max_score - 最高スコアとその曲情報を取得する 
	#---------------------------------------------------------------------
	def get_max_score
		db = DB.new(
			:SELECT => {
				'history.song' => 'song',
				'history.score_type' => 'score_type',
				'history.score' => 'score'
			} ,
			:FROM => 'history' ,
			:JOIN => ['history' , 'attendance'] ,
			:WHERE => 'attendance.user = ?' ,
			:OPTION => 'ORDER BY score DESC',
			:SET => @params['id'] ,
		)
		@max_score_history = db.execute_row
		@max_score_history['scoretype_name'] = ScoreType.id_to_name(@max_score_history['score_type'])
		get_song @max_score_history
		return @max_score_history
	end

	# addfriend - 友達を追加する
	#---------------------------------------------------------------------
	def addfriend(as_user)
		Friend.add(@params['id'] , as_user)
	end

	# get_friend_status - 指定したユーザとも友達関係を戻す
	# statusを指定した場合、そのstatusであるかを戻す
	#---------------------------------------------------------------------
	def get_friend_status(as_userid , as_status = nil)
		status = Friend.get_status(@params['id'] , as_userid)
		return as_status ? (status == as_status) : status
	end

	# friend_list - 友達関係のユーザ一覧を取得
	# statusを指定した場合、そのstatusのユーザのみ絞り込む
	#---------------------------------------------------------------------
	def friend_list(status = nil)
		friend_list = Friend.get_status(@params['id'])
		friend_info = User.id_to_name(friend_list.keys)
		friend_list.each do |userid , status|
			friend_info[userid] and friend_info[userid]['status'] = status
		end

		if status
			return friend_info.select {|k ,v| v['status'] == status}
		else
			return friend_info
		end
	end

	# timeline - 友達の最近のカラオケを取得する
	#---------------------------------------------------------------------
	def timeline(limit = 10)
		friends = self.friend_list(Util::Const::Friend::FRIEND)
		friends.empty? and return []
		qlist = Util.make_questions(friends.length)
		timeline = DB.new(
			:SELECT => {
				'attendance.karaoke' => 'karaoke_id' ,
				'attendance.user' => 'user_id' ,
				'attendance.memo' => 'memo' ,
				'karaoke.datetime' => 'datetime' ,
				'karaoke.name' => 'name' ,
				'karaoke.plan' => 'plan' ,
			} ,
			:FROM => 'attendance' ,
			:JOIN => ['attendance' , 'karaoke'] ,
			:WHERE => "attendance.user in (#{qlist})" ,
			:SET => friends.keys ,
			:OPTION => ["ORDER BY karaoke.datetime DESC" , "LIMIT #{limit}"]
		).execute_all

		timeline.each do |row|
			row['userinfo'] = friends[row['user_id']]
		end
		return timeline
	end

	# authenticate - クラスメソッド ユーザのIDとパスワードを検証する
	#---------------------------------------------------------------------
	def self.authenticate(name , pw)
		db = DB.new(:FROM => 'user' , :WHERE => ['username = ?' , 'password = ?'] , :SET => [name , pw])
		db.execute_row
	end

	# create - クラスメソッド ユーザを新規登録
	#---------------------------------------------------------------------
	def self.create(name , pw , screenname)
		db = DB.new(:FROM => 'user' , :WHERE => 'username = ?' , :SET => name)
		db.execute_row and return

		DB.new(
			:INSERT => ['user' , ['username' , 'password' , 'screenname']] ,
			:SET => [name , pw , screenname] ,
		).execute_insert_id
	end

	# id_to_name - (クラスメソッド) useridに対応するusername,screennameを戻す
	# 複数useridについてまとめて対応するので、基本的にUser.newでなくこちらを使う
	#---------------------------------------------------------------------
	def self.id_to_name(users)
		users.empty? and return []
		qlist = Util.make_questions(users.length)
		name_map = {}
		table = DB.new(
			:SELECT => ['id' , 'username' , 'screenname'] ,
			:FROM => 'user' ,
			:WHERE => "id in (#{qlist})" ,
			:SET => users
		).execute_all
		return Util.array_to_hash(table , 'id')
	end

	private
	# get_song - history['song']を元に曲情報を取得する
	#---------------------------------------------------------------------
	def get_song(history)
		song = Song.new(history['song'])
		history['song_name'] = song.params['name']
		history['artist'] = song.params['artist']
		history['artist_name'] = song.params['artist_name']
	end

end
