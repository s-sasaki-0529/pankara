#----------------------------------------------------------------------
# Store - 個々の店舗に関する情報を操作
#----------------------------------------------------------------------
require_relative 'util'
class Store < Base

  # initialize - インスタンスを生成する
  #---------------------------------------------------------------------
  def initialize(id)
    @params = DB.new.get('store' , id)
  end

  # list - クラスメソッド 店と店舗の一覧を取得
  # return { storeA => [branch1 , branch2] , storeB => [branch1 , branch2] }
  #---------------------------------------------------------------------
  def self.list(opt = nil)
    store_info = Hash.new {|h , k| h[k] = Array.new}
    rows = DB.new(:FROM => 'store').execute_all
    rows.each do |row|
      store_info[row['name']].push row['branch']
    end
    return store_info
  end

end
