#----------------------------------------------------------------------
# User - 個々のユーザアカウントに関する情報を操作
#----------------------------------------------------------------------
require_relative 'db'
class User

	attr_reader :params

	def initialize(id:)
		@params = DB.sql_row("SELECT id , username , screenname FROM user WHERE id = ?" , [id])
	end

	def initialize(username:)
		@params = DB.sql_row("SELECT id , username , screenname FROM user WHERE username = ?" , [username])
	end

end
