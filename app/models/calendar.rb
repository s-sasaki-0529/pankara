#----------------------------------------------------------------------
# Carendar - カレンダーに表示するデータを操作
#----------------------------------------------------------------------
require_relative 'base'
require_relative 'util'
require_relative 'db'
require_relative 'karaoke'
class Calendar < Base

  # 年月を指定してオブジェクトを作成。指定なしの場合本日になる
  #--------------------------------------------------------------------
  def initialize(user , year = nil , month = nil)
    if year.nil? || month.nil?
      now = Time.now
      year = now.year
      month = now.month
    end
    @user = user
    @year = year
    @month = month
  end

  # カラオケ一覧を取得
  #--------------------------------------------------------------------
  def karaoke_list(opt = {})
    # Todo: 不要なパラメータも多くてに入るので削りたい
    @karaoke = Karaoke.list(:year => @year , :month => @month , :with_attendance => true)
    @karaoke.each { |k| k['karaoke_day'] = k['karaoke_datetime'].day }
    setColorInfo()
    return @karaoke
  end

  private

  # 参加しているユーザに応じて色情報を付与
  #--------------------------------------------------------------------
  def setColorInfo()
    friends = @user.friend_list.map {|k ,v| v['username']}
    @karaoke.each do |k|
      members = k['members'].map {|m| m['username']}
      if members.include?(@user['username'])
        k['color'] = 'red'
      elsif (members & friends).length > 0
        k['color'] = 'blue'
      else
        k['color'] = 'green'
      end
    end
  end

end
