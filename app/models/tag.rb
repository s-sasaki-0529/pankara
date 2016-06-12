#----------------------------------------------------------------------
# Tag - オブジェクトに付与するタグを管理する
#----------------------------------------------------------------------
require_relative 'base'
require_relative 'util'
require_relative 'db'
class Tag < Base

  attr_reader :list

  # classとidを指定してインスタンスを生成
  #--------------------------------------------------------------------
  def initialize(_class , id)
    @class = _class
    @id = id
    @list = get_list
  end

  # list - タグの一覧を取得する
  #--------------------------------------------------------------------
  def get_list()
    @list = DB.new(
      :SELECT => 'name',
      :FROM => 'tag',
      :WHERE => ['class = ?' , 'object = ?'],
      :SET => [@class , @id]
    ).execute_columns
    return @list
  end

  # add - タグを追加する
  #--------------------------------------------------------------------
  def add(name)
    # 既に登録済みのタグの場合追加失敗
    @list.include?(name) and return false
    # タグを追加する
    insert_id = DB.new(
      :INSERT => ['tag' , ['class' , 'object' , 'name']],
      :SET => [@class , @id , name]
    ).execute_insert_id
    # 追加に成功した場合、タグリストを更新
    insert_id and get_list
    return insert_id
  end

  # remove - タグを削除
  #--------------------------------------------------------------------
  def remove(name)
    # 存在しないタグを指定した場合失敗
    @list.include?(name) or return false
    # タグを削除する
    result = DB.new(
      :DELETE => 1,
      :FROM => 'tag',
      :WHERE => ['class = ?' , 'object = ?' , 'name = ?'],
      :SET => [@class , @id , name]
    ).execute
    # 削除に成功した場合、タグリストを更新
    result and get_list and return true
  end

  # search - 指定したタグを持つidを一覧する
  #--------------------------------------------------------------------
  def self.search(_class , name , opt = {})
    DB.new(
      :SELECT => 'object',
      :FROM => 'tag',
      :WHERE => ['class = ?' , 'name = ?'],
      :SET => [_class , name],
    ).execute_columns
  end

end
