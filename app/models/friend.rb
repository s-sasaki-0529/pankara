#----------------------------------------------------------------------
# Friend - 友達関係について整理するクラス
#----------------------------------------------------------------------
require_relative 'util'
class Friend < Base

	@@list = Hash.new { |h,k| h[k] = Hash.new(0) }
	@@FRIEND = 3
	@@FOLLOW = 2
	@@FOLLOWED = 1
	@@NONE = 0

	# get_status 指定したユーザ間の友達関係を取得
	# ユーザの指定がない場合全ユーザを対象にリストを戻す
	#---------------------------------------------------------------------
	def self.get_status(user_a , user_b = nil)
		@@list.empty? and Friend.list
		user_b ? @@list[user_a][user_b] : @@list[user_a]
	end

	# list - (クラスメソッド) 全ての友達関係をクラス変数に展開する
	#---------------------------------------------------------------------
	def self.list()
		db = DB.new(:SELECT => ['user_from' , 'user_to'] , :FROM => 'friend')
		table = db.execute_all
		table.each do |row|
			from = row['user_from']
			to = row['user_to']
			@@list[from][to] += @@FOLLOW
			@@list[to][from] += @@FOLLOWED
		end
	end
end
