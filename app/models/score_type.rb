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
  def self.List(opt = {})
    score_types = DB.new(
      :SELECT => ['id' , 'brand' , 'name'] ,
      :FROM => 'score_type' ,
    ).execute_all

    # 取得する機種を制限
    if opt[:product] && opt[:product] != 'その他'
      score_types = score_types.select do |st|
        st['brand'] == opt[:product] || st['brand'] == 'その他'
      end
    end

    # ハッシュに変換せずにそのまま取得
    opt[:wantarray] and return score_types

    # idをkeyとしたハッシュに変換して戻す
    score_types.each do |score_type|
      @@list[score_type['id']] = {
        'brand' => score_type['brand'] ,
        'name' => score_type['name'] ,
      }
    end
    return score_types
  end

  #---------------------------------------------------------------------
  # id_to_name - 指定したIDに対応する採点モード名を戻す
  #---------------------------------------------------------------------
  def self.id_to_name(id , opt = {})
    if @@list.empty? || Util.run_mode == 'ci'
      self.List
    end

    id.kind_of?(String) and id = id.to_i
    if opt[:hash]
      @@list[id] ? @@list[id] : {'brand' => '' , 'name' => ''}
    else
      @@list[id] ? @@list[id]['name'] : ""
    end

  end
end
