#----------------------------------------------------------------------
# User_attr - ユーザ属性
#----------------------------------------------------------------------
require_relative 'base'
require_relative 'util'
require_relative 'db'
class UserAttr < Base

  # userIDでインスタンスを生成
  #--------------------------------------------------------------------
  def initialize(user_id)
    @user = user_id
  end

  # ユーザ属性を取得
  #--------------------------------------------------------------------
  def get(attr)
    DB.new(
      :SELECT => 'value',
      :FROM => 'user_attr',
      :WHERE => ['user = ?' , 'attr = ?'],
      :SET => [@user , attr]
    ).execute_column
  end

  # ユーザ属性を設定
  #--------------------------------------------------------------------
  def set(attr , value)
    if self.get(attr)
      DB.new(
        :UPDATE => ['user_attr' , ['value']],
        :WHERE => ['user = ?' , 'attr = ?'],
        :SET => [value , @user , attr]
      ).execute
    else
      return DB.new(
        :INSERT => ['user_attr' , ['user' , 'attr' , 'value']] ,
        :SET => [@user , attr , value]
      ).execute_insert_id
    end
  end

end
