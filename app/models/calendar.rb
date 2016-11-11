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
    karaoke = Karaoke.list(:year => @year , :month => @month)
    karaoke.each do |k|
      # 日のみを抽出
      k['karaoke_day'] = k['karaoke_datetime'].day
   end
  end

end
