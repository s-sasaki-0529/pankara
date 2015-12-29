#----------------------------------------------------------------------
# User - 個々のユーザアカウントに関する情報を操作
#----------------------------------------------------------------------
require_relative 'db'
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

end
