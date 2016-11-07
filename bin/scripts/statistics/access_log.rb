#----------------------------------------------------------------------
# AccessLog - アクセスログを管理するクラス
#----------------------------------------------------------------------

class AccessLog

  attr_reader :log_data_list
  
  # initialize - Hashでログデータを設定する
  #--------------------------------------------------------------------
  def initialize(log_data_list)
    @log_data_list = log_data_list
  end

  # from - 設定された下限値に応じて不要なデータをlog_dataから削除する
  #--------------------------------------------------------------------
  def from(date)
    @log_data_list.select! { | log | log['date'].split(' ')[0] >= date }
  end

  # to - 設定された上限値に応じて不要なデータをlog_dataから削除する
  #--------------------------------------------------------------------
  def to(date)
    @log_data_list.select! { | log | log['date'].split(' ')[0] <= date }
  end

  # get_unique_access_log_list - ユニークなアクセスのみを取得する
  #--------------------------------------------------------------------
  def get_unique_access_log_list(log_data_list)
    unique_log_list = Array.new
    
    log_data_list.each do | log |
      unique_log_list.push(log) if is_unique?(unique_log_list, log['ip'])
    end

    return unique_log_list
  end

  # get_each_data_log_hash - 各データごとのアクセスログを取得する
  #--------------------------------------------------------------------
  def get_each_data_log_hash(data_name, log_data_list)
    each_data_log_hash = Hash.new
   
    log_data_list.each do | log |
      unless each_data_log_hash.key? log[data_name]
        each_data_log_hash[log[data_name]] = Array.new
      end
      
      each_data_log_hash[log[data_name]].push(log)
    end

    return each_data_log_hash
  end

  # get_each_day_log_hash - 日にちごとのアクセスログを取得する
  #--------------------------------------------------------------------
  def get_each_day_log_hash(log_data_list)
    each_day_log_hash = Hash.new
    
    log_data_list.each do | log |
      date = log['date'].split(' ')[0]
      unless each_day_log_hash.key? date
        each_day_log_hash[date] = Array.new
      end
      
      each_day_log_hash[date].push(log)
    end

    return each_day_log_hash
  end
  
  # sort_in_num_of_access_order_by - 指定した順に、アクセス数で並び替える
  #--------------------------------------------------------------------
  def sort_in_num_of_access_order_by(order, each_day_access_hash)
    case order
    when 'asc'  
      return each_day_access_hash.sort { | (date1, num1), (date2, num2) | num1 <=> num2 }
    when 'desc'
      return each_day_access_hash.sort { | (date1, num1), (date2, num2) | num2 <=> num1 }
    else
      return each_day_access_hash
    end
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
  
end
