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

  # print_num_of_access - 総アクセス数とユニークアクセス数を標準出力する
  #--------------------------------------------------------------------
  def print_num_of_access
    puts "総アクセス数:   #{@log_data_list.size}回"
    puts "ユニークアクセス数:   #{get_unique_access_log(@log_data_list).size}回"
  end
    
  # print_num_of_each_day_access - 日ごとの総アクセス数とユニークアクセス数を標準出力する
  #--------------------------------------------------------------------
  def print_num_of_each_day_access
    puts '総アクセス数:'
    get_each_day_log(@log_data_list).each do | day, log_data_list |
      puts "%-20s%s回"%[day, log_data_list.size]
    end
    puts

    puts "ユニークアクセス数:"
    get_each_day_log(@log_data_list).each do | day, log_data_list |
      puts "%-20s%s回"%[day, get_unique_access_log(log_data_list).size]
    end
  end
  
  # print_each_data_log - 各データごとの集計を出力する
  #--------------------------------------------------------------------
  def print_each_data_log(data_name)
    each_data_log_hash = get_each_data_log(data_name, @log_data_list)

    puts "#{data_name}の種類ごとのアクセス数"
    each_data_log_hash.each do | key, each_log_list |
      puts "%-40s%s回"%[key, each_log_list.size]
    end
  end
  
  # get_unique_access_log - ユニークなアクセスのみを取得する
  #--------------------------------------------------------------------
  private
  def get_unique_access_log(log_data_list)
    unique_log_list = Array.new
    
    log_data_list.each do | log |
      unique_log_list.push(log) if is_unique?(unique_log_list, log['ip'])
    end

    return unique_log_list
  end

  # is_unique? - "unique_log_list"が"ip"を持っていないか判定する
  #--------------------------------------------------------------------
  private
  def is_unique?(unique_log_list, ip)
    unique_log_list.each do | log |
      return false if log.has_value?(ip)
    end

    return true
  end
  
  # get_each_data_log - 各データごとのアクセスログを取得する
  #--------------------------------------------------------------------
  private
  def get_each_data_log(data_name, log_data_list)
    each_data_log_hash = Hash.new
    
    log_data_list.each do | log |
      unless each_data_log_hash.key? log[data_name]
        each_data_log_hash[log[data_name]] = Array.new
      end
      
      each_data_log_hash[log[data_name]].push(log)
    end

    return each_data_log_hash
  end

  # get_each_day_log - 日にちごとのアクセスログを取得する
  #--------------------------------------------------------------------
  private
  def get_each_day_log(log_data_list)
    each_day_log_hash = Hash.new
    
    log_data_list.each do | log |
      unless each_day_log_hash.key? log['date']
        each_day_log_hash[log['date']] = Array.new
      end
      
      each_day_log_hash[log['date']].push(log)
    end

    return each_day_log_hash
  end

end
