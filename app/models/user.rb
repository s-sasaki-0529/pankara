#----------------------------------------------------------------------
# User - 個々のユーザアカウントに関する情報を操作
#----------------------------------------------------------------------
require_relative 'util'
class User

	attr_reader :params

	# initialize(username:) - usernameを指定してインスタンスを生成
	#---------------------------------------------------------------------
	def initialize(username)
		db = DB.new
		db.from('user')
		db.where('username = ?')
		db.set(username)
		@params = db.execute_row
	end

	# histories - 歌唱履歴を取得
	#---------------------------------------------------------------------
	def histories
		db = DB.new
		db.select({
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
		db.option('ORDER BY datetime DESC')
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

	# get_karaoke
	#---------------------------------------------------------------------
	def get_karaoke
		# 対象ユーザが参加したkaraokeのID一覧を取得
		db = DB.new
		db.select('karaoke')
		db.from('attendance')
		db.where('user = ?')
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
		price = params[:price].to_i
		memo = params[:memo]

		db = DB.new
		db.insert('karaoke' , ['datetime' , 'plan' , 'store' , 'product' , 'price' , 'memo'])
		db.set(datetime , plan , store , product , price , memo)
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

end
