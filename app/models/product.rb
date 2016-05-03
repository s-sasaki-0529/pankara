#----------------------------------------------------------------------
# Product - 個々の機種に関する情報を操作
#----------------------------------------------------------------------
require_relative 'base'
require_relative 'util'
require_relative 'db'
class Product < Base

  @@list = {}

  # initialize - インスタンスを生成する
  #---------------------------------------------------------------------
  def initialize(id)
    @params = DB.new.get('product' , id)
  end

  # list - idと機種情報の対応を取得する
  #---------------------------------------------------------------------
  def self.list()
    products = DB.new(:FROM => 'product').execute_all
    products.each do |product|
      @@list[product['id']] = {
        'brand' => product['brand'], 
        'product' => product['product']
      }
    end
  end

  # get - 指定したidに対応する機種情報を取得する
  #---------------------------------------------------------------------
  def self.get(id = nil)
    id or return nil
    @@list.empty? and self.list
    @@list[id] ? @@list[id] : nil
  end

end
