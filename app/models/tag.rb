#----------------------------------------------------------------------
# Tag - オブジェクトに付与するタグを管理する
#----------------------------------------------------------------------
require_relative 'base'
require_relative 'util'
require_relative 'db'
class Tag < Base

  # classとidを指定してインスタンスを生成
  #--------------------------------------------------------------------
  def initialize(_class , id)
    @class = _class
    @id = id
  end

  # add - タグを追加する
  #--------------------------------------------------------------------
  def add(name)
    DB.new(
      :INSERT => ['tag' , ['class' , 'object' , 'name']],
      :SET => [@class , @id , name]
    ).execute_insert_id
  end

end
