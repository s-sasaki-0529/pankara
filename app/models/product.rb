#----------------------------------------------------------------------
# Product - 個々の機種に関する情報を操作
#----------------------------------------------------------------------
require_relative 'db'
class Product

	attr_reader :params

	# initialize - インスタンスを生成する
	#---------------------------------------------------------------------
	def initialize(id)
		@params = DB.sql_row("SELECT * FROM product WHERE id = ?" , [id])
	end

end
