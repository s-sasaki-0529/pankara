#----------------------------------------------------------------------
# DB - データベースに直接アクセスするクラス
#----------------------------------------------------------------------
require 'mysql'
class DB

	@@db = nil

	# initialize - mysqlサーバへの接続を行う
	#---------------------------------------------------------------------
	def self.init
		@@db = Mysql.new('127.0.0.1' , 'root' , 'zenra' , 'march')
		@@db.charset = 'utf8'
	end

	# sql_row - SQLを実行し、先頭行をハッシュ形式で取得
	#---------------------------------------------------------------------
	def self.sql_row(sql , params = [])
		st = self.sql(sql , params)
		return st.fetch_hash
	end

	# sql_all - SQLを実行し、結果をハッシュの配列形式で取得
	#---------------------------------------------------------------------
	def self.sql_all(sql , params = [])
		result = []
		st = self.sql(sql , params)
		while (h = st.fetch_hash)
			result.push h
		end
		return result
	end

	# sql_insert_id - SQLを実行し、insert_idを戻す
	#--------------------------------------------------------------------
	def self.sql_insert_id(sql , params = [])
		st = self.sql(sql , params)
		st.insert_id
	end

	# sql - SQLを実行
	#---------------------------------------------------------------------
	def self.sql(sql , params = [])
		st = @@db.prepare(sql)
		st.execute(*params)
		return st
	end

end
