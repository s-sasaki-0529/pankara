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

  # get_tweet_karaoke_format - カラオケについてのツイートのフォーマットを取得
  #--------------------------------------------------------------------------
  def get_tweet_karaoke_format
    format = self.get('tweet-karaoke-format')
    format ? format : "$$username$$さんがカラオケに行きました $$url$$"
  end

  # get_tweet_history_format - 歌唱履歴についてのツイートのフォーマットを取得
  #--------------------------------------------------------------------------
  def get_tweet_history_format
    format = self.get('tweet-history-format')
    format ? format : "$$song$$($$artist$$)を歌いました $$url$$"
  end

  # set_tweet_karaoke_format - カラオケについてのツイートのフォーマットを設定
  #--------------------------------------------------------------------------
  def set_tweet_karaoke_format(format)
    self.set('tweet-karaoke-format' , format)
  end

  # set_tweet_history_format - 歌唱履歴についてのツイートのフォーマットを設定
  #--------------------------------------------------------------------------
  def set_tweet_history_format
    self.set('tweet-history-format' , format)
  end

end
