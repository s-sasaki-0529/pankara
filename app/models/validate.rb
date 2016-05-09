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
  
  # validate_user_info - クラスメソッド 入力されたユーザ情報がフォーマットに沿っているか確認する
  #---------------------------------------------------------------------
  def self.validate_user_info(name , password , screenname)
    is_screenname?(screenname) or return Util.error('ニックネームは4文字以上16文字以下で入力してください。または使用できない文字が使用されています。' , 'hash')
    is_username?(name) or return Util.error('ユーザ名は4文字以上16文字以下の半角英数字で入力してください。' , 'hash')
    is_password?(password) or return Util.error('パスワードは4文字以上の半角英数字で入力してください。' , 'hash')
    return {:result => 'successful'}
  end

  # is_screenname? - March標準のニックネームのフォーマットに沿っているかを戻す
  #--------------------------------------------------------------------
  private
  def self.is_screenname?(screenname)
    if screenname.match(%r|.{2,16}|)
      true
    else
      false
    end
  end

  # is_username? - March標準のユーザ名のフォーマットに沿っているかを戻す
  #--------------------------------------------------------------------
  private
  def self.is_username?(username)
    if username.match(%r|\w{4,16}|)
      true
    else
      false
    end
  end
  
  # is_password? - March標準のパスワードのフォーマットに沿っているかを戻す
  #--------------------------------------------------------------------
  private
  def self.is_password?(password)
    if password.match(%r|\w{4,}|)
      true
    else
      false
    end
  end
  
end
