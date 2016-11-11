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
  def initialize(year = nil , month = nil)
    if year.nil? || month.nil?
      now = Time.now
      year = now.year
      month = now.month
    end
    @year = year
    @month = month
  end

  # カラオケ一覧を取得
  #--------------------------------------------------------------------
  def karaoke_list(opt = {})
    Karaoke.list(:year => @year , :month => @month)
  end

end
