#----------------------------------------------------------------------
# User - 個々のユーザアカウントに関する情報を操作
#----------------------------------------------------------------------
require_relative 'db'
require_relative 'song'
require_relative 'karaoke'
class User

	attr_reader :params

	# initialize(username:) - usernameを指定してインスタンスを生成
	#---------------------------------------------------------------------
	def initialize(username)
		@params = DB.sql_row("SELECT id , username , screenname FROM user WHERE username = ?" , [username])
	end

	# histories - 歌唱履歴を取得
	#---------------------------------------------------------------------
	def histories
		histories = DB.sql_all(
			"SELECT datetime , history.song , history.songkey
			FROM ( history JOIN attendance ON history.attendance = attendance.id)
			JOIN karaoke ON karaoke.id = attendance.karaoke
			WHERE attendance.user = ?
			ORDER BY datetime DESC;" , [@params['id']]
		)
		histories.each do | history |
			song = Song.new(history['song'])
			history['song_name'] = song.params['name']
			history['artist_name'] = song.params['artist_name']
		end
		return histories
	end

	# get_karaoke
	#---------------------------------------------------------------------
	def get_karaoke
		attended_id_list = DB.sql_all(
			"SELECT karaoke FROM attendance WHERE user = ?" ,
			[@params['id']]
		).collect {|info| info['karaoke']}

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

		karaoke_id = DB.sql_insert_id("
			INSERT INTO karaoke ( datetime , plan , store , product , price , memo )
			VALUES ( ? , ? , ? , ? , ? , ? );
		" , [datetime , plan , store , product , price , memo])

		attendance_id = DB.sql_insert_id("
			INSERT INTO attendance ( user , karaoke )
			VALUES ( ? , ? );
		" , [self.params['id'] , karaoke_id])
	end

	# authenticate - クラスメソッド ユーザのIDとパスワードを検証する
	#---------------------------------------------------------------------
	def self.authenticate(name , pw)
		DB.sql_row("SELECT * FROM user WHERE username = ? and password = ?" , [name , pw])
	end

end
