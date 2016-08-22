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
      puts "日付:        #{log['date']}"
      puts "IPアドレス:  #{log['ip']}"
      puts "ユーザ:      #{log['user']}"
      puts "URL:         #{log['url']}"
      puts "リファラ:    #{log['referer']}"
      puts "デバイス:    #{log['device']}"
      puts "OS:          #{log['os']}"
      puts "ブラウザ:    #{log['blowser']}"
      puts
    end
  end

  # print_num_of_access - ログを標準出力する
  #--------------------------------------------------------------------
  def print_num_of_access
    puts "総アクセス数:         #{count_total_access}回"
    puts "ユニークアクセス数:   #{count_unique_access}回"
  end
  
  # print_each_data - 各データごとの集計を出力する
  #--------------------------------------------------------------------
  def print_each_data(data_name)
    counter_hash = count_each(data_name)

    puts "#{data_name}の種類ごとのアクセス数"
    counter_hash.each do | key, value |
      puts "%-40s%s回"%[key, value]
    end
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
  
  # count_each - 各データごとのアクセス数を取得する
  #--------------------------------------------------------------------
  private
  def count_each(data_name)
    counter_hash = Hash.new
    
    @log_data_list.each do | log |
      if counter_hash.key? log[data_name]
        counter_hash[log[data_name]] += 1
      else
        counter_hash[log[data_name]] = 1
      end
    end

    return counter_hash
  end


end
