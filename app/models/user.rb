#----------------------------------------------------------------------
# User - 個々のユーザアカウントに関する情報を操作
#----------------------------------------------------------------------
require_relative 'db'
require_relative 'song'
class User

	attr_reader :params

	# initialize(id:) - idを指定してインスタンスを生成
	#---------------------------------------------------------------------
	def initialize(id:)
		@params = DB.sql_row("SELECT id , username , screenname FROM user WHERE id = ?" , [id])
	end

	# initialize(username:) - usernameを指定してインスタンスを生成
	#---------------------------------------------------------------------
	def initialize(username:)
		@params = DB.sql_row("SELECT id , username , screenname FROM user WHERE username = ?" , [username])
	end

	# histories - 歌唱履歴を取得
	#---------------------------------------------------------------------
	def histories
		histories = DB.sql_all(
			"SELECT datetime , history.song , history.songkey
			FROM ( history JOIN attendance ON history.attendance = attendance.id)
			JOIN karaoke ON karaoke.id = attendance.karaoke
			WHERE attendance.user = ?" , [@params['id']]
		)
		histories.each do | history |
			song = Song.new(history['song'])
			history['song_name'] = song.params['name']
			history['artist_name'] = song.artist_name
		end
		return histories
	end

end
