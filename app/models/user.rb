#----------------------------------------------------------------------
# User - 個々のユーザアカウントに関する情報を操作
#----------------------------------------------------------------------
require_relative 'util'
class User < Base

	# initialize(username:) - usernameを指定してインスタンスを生成
	#---------------------------------------------------------------------
	def initialize(username)
		db = DB.new
		db.from('user')
		db.where('username = ?')
		db.set(username)
		@params = db.execute_row
	end

	# histories - 歌唱履歴を取得、limitを指定するとその行数だけ取得
	#---------------------------------------------------------------------
	def histories(limit = 0)
		db = DB.new
		db.select({
			'karaoke.name' => 'karaoke_name' ,
			'karaoke.datetime' => 'datetime' ,
			'history.song' => 'song' ,
			'history.songkey' => 'songkey'
		})
		db.from('history')
		db.join(
			['history' , 'attendance'] ,
			['attendance' , 'karaoke']
		)
		db.where('attendance.user = ?')
		option = ['ORDER BY datetime DESC']
		option.push("LIMIT #{limit}") if limit > 0
		db.option(option)
		db.set(@params['id'])
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
		db = DB.new
		db.select('karaoke')
		db.from('attendance')
		db.where('user = ?')
		db.option("LIMIT #{limit}") if limit > 0
		db.set(@params['id'])
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

		db = DB.new
		db.insert('karaoke' , ['datetime' , 'plan' , 'store' , 'product'])
		db.set(datetime , plan , store , product)
		karaoke_id = db.execute_insert_id

		db = DB.new
		db.insert('attendance' , ['user' , 'karaoke'])
		db.set(@params['id'] , karaoke_id)
		db.execute_insert_id
	end

	# authenticate - クラスメソッド ユーザのIDとパスワードを検証する
	#---------------------------------------------------------------------
	def self.authenticate(name , pw)
		db = DB.new
		db.from('user')
		db.where('username = ?' , 'password = ?')
		db.set(name , pw)
		db.execute_row
	end

	# get_most_sang_song - 最も歌っている曲を取得する 
	#---------------------------------------------------------------------
	def get_most_sang_song
		db = DB.new
		db.select({'history.song' => 'song', 'COUNT(*)' => 'counter'})
		db.from('history')
		db.join(['history', 'attendance'])
		db.where('attendance.user = ?')
		db.option(['GROUP BY song', 'ORDER BY counter DESC, history.created_at DESC'])
		db.set(@params['id'])
		@most_sang_song = db.execute_row

		get_song @most_sang_song
		return @most_sang_song
	end

	# get_most_sang_artist - 最も歌っている歌手を取得する 
	#---------------------------------------------------------------------
	def get_most_sang_artist
		db = DB.new
		db.select({'song.artist' => 'artist', 'COUNT(*)' => 'counter'})
		db.from('history')
		db.join(
			['history', 'attendance'],
			['history', 'song']
		)
		db.where('attendance.user = ?')
		db.option(['GROUP BY artist', 'ORDER BY counter DESC, history.created_at DESC'])
		db.set(@params['id'])
		@most_sang_artist = db.execute_row

		db= DB.new
		db.select('name')
		db.from('artist')
		db.where('id = ?')
		db.set(@most_sang_artist['artist'])
		@most_sang_artist['artist_name'] = db.execute_column
		return @most_sang_artist
	end

	# get_max_score - 最高スコアとその曲情報を取得する 
	#---------------------------------------------------------------------
	def get_max_score
		db = DB.new
		db.select({
			'history.song' => 'song',
			'history.score_type' => 'score_type',
			'MAX(history.score)' => 'score'
		})
		db.from('history')
		db.join(
			['history', 'attendance'],
		)
		db.where('attendance.user = ?')
		db.set(@params['id'])
		@max_score_history = db.execute_row

		get_song @max_score_history
		return @max_score_history
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
