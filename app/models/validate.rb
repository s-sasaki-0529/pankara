#----------------------------------------------------------------------
# Validate - 対象テキストを検証するクラス
#----------------------------------------------------------------------
require_relative 'util'
class Validate
  
  # is_datetime? - March標準の日付時刻フォーマットに沿っているかを戻す
  #--------------------------------------------------------------------
  def self.is_datetime?(datetime)
    if datetime.match(%r|[0-9]{4}.[0-9]{2}.[0-9]{2} [0-9]{2}:[0-9]{2}|)
      true
    else
      false
    end
  end

end
