#----------------------------------------------------------------------
# DB - データベースに直接アクセスするクラス
#----------------------------------------------------------------------
require 'mysql'
class DB

	@@db = nil

	# initialize - インスタンス生成
	#---------------------------------------------------------------------
	def initialize
		@select = ''
		@from = ''
		@join = ''
		@where = ''
		@option = ''
		@params = []
	end

	# connect - mysqlサーバへの接続を行う
	#---------------------------------------------------------------------
	def self.connect
		@@db = Mysql.new('127.0.0.1' , 'root' , 'zenra' , 'march')
		@@db.charset = 'utf8'
	end

	# select - SELECT文を作成する
	#---------------------------------------------------------------------
	def select(*params)
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

		@select = "SELECT #{selects.join(',')}"
	end

	# from - FROM文を作成する
	#---------------------------------------------------------------------
	def from(*params)
		@from = "FROM #{params.join(',')}"
	end

	# where - WHERE分を作成する
	#---------------------------------------------------------------------
	def where(*params)
		@where = "WHERE #{params.join(' and ')}"
	end

	# join - JOIN文を作成する
	#---------------------------------------------------------------------
	def join(*params)
		sql = []
		params.each do |set|
			sql.push  "JOIN #{set[1]} ON #{set[0]}.#{set[1]} = #{set[1]}.id"
		end
		@join = sql.join(' ')
	end

	# option - ORDER BY / LIMIT などその他の構文を作成
	#---------------------------------------------------------------------
	def option(*params)
		@option = params.join(' ')
	end

	# set - prepareに引き渡すパラメータをセットする
	#---------------------------------------------------------------------
	def set(*params)
		@params = params
	end

	# execute_column - SQLを実行し、先頭行先頭列の値を戻す
	#---------------------------------------------------------------------
	def execute_column
		make
		st = self.execute
		result = st.fetch_hash
		return nil if result.nil?
		return result.values.to_a[0]	
	end

	# execute_row - SQLを実行し、先頭行を戻す
	#---------------------------------------------------------------------
	def execute_row
		make
		st = self.execute
		return st.fetch_hash
	end
	
	# execute_all - SQLを実行し、結果をハッシュ配列の形式で戻す
	#---------------------------------------------------------------------
	def execute_all
		result = []
		make
		st = self.execute
		while (h = st.fetch_hash)
			result.push h
		end
		return result
	end

	# execute_insert_id - SQLを実行後、挿入レコードのIDを戻す
	#---------------------------------------------------------------------
	def execute_insert_id
		make
		st = self.execute
		st.insert_id
	end

	# execute - SQLを実行する
	#---------------------------------------------------------------------
	def execute
		make
		st = @@db.prepare(@sql)
		st.execute(*@params)
		return st
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

	# make - SQL分を生成する
	#---------------------------------------------------------------------
	private
	def make
		@sql = [@select , @from , @join , @where , @option].join(' ')
	end

end
