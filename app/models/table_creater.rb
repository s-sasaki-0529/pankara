#----------------------------------------------------------------------
# TableCreater - テーブル用ハッシュ生成クラス
#----------------------------------------------------------------------
require_relative 'util'
class TableCreater < Base

	# initialize - インスタンスを生成する
	#---------------------------------------------------------------------
	def initialize()
		@table_tag = {}
		@header = {}
		@body = {}
		@body['tr'] = []
		@item_symbol = []
	end

	# set_table_attr - テーブルのタグを設定する
	# 各値をハッシュで設定する
	#---------------------------------------------------------------------
	def set_table_attr(params)
		@table_tag['id'] = params['id']
		@table_tag['width'] = params['width']
		@table_tag['class'] = params['class'].join(' ')
	end

	# set_column_name - テーブルの列名を設定する
	# 列名をハッシュで指定する 
	#---------------------------------------------------------------------
	def set_column_name(param)
		@header['name'] = param
		@item_symbol = param.keys
	end

	# set_header_attr - テーブルのヘッダに属性を設定する
	#---------------------------------------------------------------------
	def set_header_attr(params)
		params.each do |key, value|
			@header[key] = value.join(' ')
		end
	end

	# body - テーブルのitemを設定する
	# 各値をハッシュで指定する 
	#---------------------------------------------------------------------
	def set_item(param)
		@body['item'] = param
	end

	# set_body_row_attr - ボディの行に属性を設定する
	#---------------------------------------------------------------------
	def set_body_row_attr(params)
		params.each_with_index do |param, i|
			@body['tr'][i] = {}
			param.each do |key, value|
				@body['tr'][i][key] = value.join(' ')
			end
		end
	end

	# create_table - テーブル用ハッシュを作成して取得する
	#---------------------------------------------------------------------
	def create_table()
		if @table_tag.empty? 
			@table_tag['id'] = 'table'
			@table_tag['width'] = 600
		end

		if @body['tr'].size < @body['item'].size
			for i in @body['tr'].size..(@body['item'].size - 1)
				@body['tr'][i] = {}
			end
		end

		if @item_symbol.empty?
			@item_symbol = @body['item'][0].keys
		end

		table = {}
		table['table_tag'] = @table_tag
		table['header'] = @header
		table['body'] = @body
		table['item_symbol'] = @item_symbol

		return table
	end

end
