#----------------------------------------------------------------------
# ScoreType - 採点モードに関する情報
#----------------------------------------------------------------------
require_relative 'base'
require_relative 'util'
require_relative 'db'
class ScoreType < Base

  @@list = {}

  #--------------------------------------------------------------------
  # List - idと採点モード名の対応を取得
  #--------------------------------------------------------------------
  def self.List(wanthash = false)
    score_types = DB.new(
      :SELECT => ['id' , 'brand' , 'name'] ,
      :FROM => 'score_type' ,
    ).execute_all

    wanthash and return score_types

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
    if @@list.empty? || Util.run_mode == 'ci'
      self.List
    end

    id.kind_of?(String) and id = id.to_i
    if wanthash
      @@list[id] ? @@list[id] : {'brand' => '' , 'name' => ''}
    else
      @@list[id] ? @@list[id]['name'] : ""
    end

  end
end
