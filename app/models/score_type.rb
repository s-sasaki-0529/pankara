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
		score_types = DB.new(
			:SELECT => ['id' , 'brand' , 'name'] ,
			:FROM => 'score_type' ,
		).execute_all

		score_types.each do |score_type|
			@@list[score_type['id']] = {
				'brand' => score_type['brand'] ,
				'name' => score_type['name'] ,
			}
		end
	end

	#---------------------------------------------------------------------
	# id_to_name - 指定したIDに対応する採点モード名を戻す
	#---------------------------------------------------------------------
	def self.id_to_name(id , wanthash = false)
		@@list.empty? and self.List
		if wanthash
			@@list[id] ? @@list[id] : {'brand' => '' , 'name' => ''}
		else
			@@list[id] ? @@list[id]['name'] : ""
		end
	end
end
