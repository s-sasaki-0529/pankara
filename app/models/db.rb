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

	# select - SELECT文を作成する
	#---------------------------------------------------------------------
	def self.select(*params)
		as_hash = {}
		params.each do |param|
			if param.kind_of?(Hash)
				hash = param
			elsif param.kind_of?(String)
				hash = {param => param}
			end
			as_hash.merge! hash
		end

		selects = []
		as_hash.each do |key , val|
			selects.push "#{key} AS #{val}"
		end

		return "SELECT #{selects.join(',')}"
	end

	# from - FROM文を作成する
	#---------------------------------------------------------------------
	def self.from(*params)
		"FROM #{params.join(',')}"
	end

	# where - WHERE分を作成する
	#---------------------------------------------------------------------
	def self.where(*params)
		"WHERE #{params.join(' and ')}"
	end

	# join - JOIN文を作成する
	#---------------------------------------------------------------------
	def self.join(*params)
		sql = []
		params.each do |set|
			sql.push  "JOIN #{set[1]} ON #{set[0]}.#{set[1]} = #{set[1]}.id"
		end
		return sql.join(' ')
	end

	# get - 対象テーブルから特定のレコードを取得
	#---------------------------------------------------------------------
	def self.get(table , id)
		self.sql_row("SELECT * FROM #{table} WHERE id = ?" , id)
	end

	# all - 対象テーブルから全レコードを取得
	#---------------------------------------------------------------------
	def self.all(table)
		self.sql_row("SELECT * FROM #{table}")
	end

	# sql_column - SQLを実行し、先頭行先頭列の値のみ戻す
	#---------------------------------------------------------------------
	def self.sql_column(sql , params = [])
		st = self.sql(sql , params)
		result = st.fetch_hash
		return nil if result.nil?
		return result.values.to_a[0]
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
