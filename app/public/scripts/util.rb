#----------------------------------------------------------------------
# Util - 広い範囲で使われる汎用的なスクリプト
#----------------------------------------------------------------------

require 'mysql'
class Util
	
	# get_message - メッセージコードを元にファイルからテキストを取得する
	#---------------------------------------------------------------------
	def self.get_message(code)
		messages = eval File.read 'app/public/message/errors.rb'
		mes = messages[code]
		mes = 'Unknown Message' if mes.nil?
		mes
	end

end
