#----------------------------------------------------------------------
# Validate - 対象テキストを検証するクラス
#----------------------------------------------------------------------
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
  
  # is_in_range? - 文字数が指定した範囲内かを戻す
  #---------------------------------------------------------------------
  def self.is_in_range?(str , min , max)
    if str.length >= min and str.length <= max
      true
    else
      false
    end
  end

  # include_special_character? - 特殊文字が含まれているかを戻す
  #--------------------------------------------------------------------
  def self.include_special_character?(str)
    if str.match(%r|[<>$#%&"'!\s]|)
      true
    else
      false
    end
  end

  # is_username? - March標準のユーザ名のフォーマットに沿っているかを戻す
  #--------------------------------------------------------------------
  def self.is_username?(username)
    if username.match(%r|^\w{4,16}$|)
      true
    else
      false
    end
  end
  
  # is_password? - March標準のパスワードのフォーマットに沿っているかを戻す
  #--------------------------------------------------------------------
  def self.is_password?(password)
    if password.match(%r|^\w{4,}$|)
      true
    else
      false
    end
  end
  
end
