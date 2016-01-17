#----------------------------------------------------------------------
# ScoreType - 採点モードに関する情報
#----------------------------------------------------------------------
require_relative 'util'
class ScoreType < Base
	
	@@list = {}

	#--------------------------------------------------------------------
	# List - idと採点モード名の対応を取得
	#--------------------------------------------------------------------
	def self.List
		db = DB.new
		db.select('id' , 'brand' , 'name')
		db.from('score_type')
		db.execute_all.each do |score_type|
			@@list[score_type['id']] = {
				'brand' => score_type['brand'] ,
				'name' => score_type['name'] ,
			}
		end
	end

	#---------------------------------------------------------------------
	# id_to_name - 指定したIDに対応する採点モード名を戻す
	#---------------------------------------------------------------------
	def self.id_to_name(id)
		@@list.empty? and self.List
		@@list[id] ? @@list[id]['name'] : nil
	end
end
