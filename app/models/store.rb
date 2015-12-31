#----------------------------------------------------------------------
# Store - 個々の店舗に関する情報を操作
#----------------------------------------------------------------------
require_relative 'db'
class Store

	attr_reader :params

	# initialize - インスタンスを生成する
	#---------------------------------------------------------------------
	def initialize(id)
		@params = DB.sql_row("SELECT * FROM store WHERE id = ?" , [id])
	end

end
