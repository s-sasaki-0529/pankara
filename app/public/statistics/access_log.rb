#----------------------------------------------------------------------
# AccessLog - アクセスログを管理するクラス
#----------------------------------------------------------------------

class AccessLog

  # initialize - Hashでログデータを設定する
  #--------------------------------------------------------------------
  def initialize(log_data_list)
    @log_data_list = log_data_list
  end

  # from - 設定された下限値に応じて不要なデータをlog_dataから削除する
  #--------------------------------------------------------------------
  def from(date)
    @log_data_list.select! { | log | log['date'] >= date }
  end

  # to - 設定された上限値に応じて不要なデータをlog_dataから削除する
  #--------------------------------------------------------------------
  def to(date)
    @log_data_list.select! { | log | log['date'] <= date }
  end

  # print - ログを標準出力する
  #--------------------------------------------------------------------
  def print
    @log_data_list.each do | log |
      p "日付:        #{log['date']}"
      p "IPアドレス:  #{log['ip']}"
      p "ユーザ:      #{log['user']}"
      p "URL:         #{log['url']}"
      p "リファラ:    #{log['referer']}"
      p "デバイス:    #{log['device']}"
      p "OS:          #{log['os']}"
      p "ブラウザ:    #{log['blowser']}"
      puts
    end
  end

  # print_num_of_access - ログを標準出力する
  #--------------------------------------------------------------------
  def print_num_of_access
    p "総アクセス数:         #{count_total_access}"
    p "ユニークアクセス数:   #{count_unique_access}"
  end
  
  # count_total_access - 総アクセス数を取得する
  #--------------------------------------------------------------------
  private
  def count_total_access
    return @log_data_list.size
  end

  # count_unique_access - ユニークアクセス数を取得する
  #--------------------------------------------------------------------
  private
  def count_unique_access
    unique_log_list = Array.new
    
    @log_data_list.each do | log |
      unique_log_list.push(log) if is_unique?(unique_log_list, log['ip'])
    end

    return unique_log_list.size
  end

  # is_unique? - "unique_log_list"が"ip"を持っているか判定する
  #--------------------------------------------------------------------
  private
  def is_unique?(unique_log_list, ip)
    unique_log_list.each do | log |
      return false if log.has_value?(ip)
    end

    return true
  end

end
