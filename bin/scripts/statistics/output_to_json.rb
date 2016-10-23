#----------------------------------------------------------------------
# Output - 解析結果をJSON形式で出力するクラス
#----------------------------------------------------------------------
require 'json'

require_relative 'access_log'

class OutputToJson

  def initialize(access_log)
    @access_log = access_log
  end

  # print - ログを出力する
  #--------------------------------------------------------------------
  def print_all_log_list
    @access_log.log_data_list.each do | log |
      puts JSON.generate(log)
    end
  end

  # print_num_of_each_day_access - 日ごとの総アクセス数とユニークアクセス数を出力する
  #--------------------------------------------------------------------
  def print_num_of_each_day_access(order)
    each_day_log_hash = @access_log.get_each_day_log_hash(@access_log.log_data_list)
    
    each_day_access_hash = Hash.new
    each_day_log_hash.each { | day, log_data_list | each_day_access_hash.store(day, log_data_list.size) }
    @access_log.sort_in_num_of_access_order_by(order, each_day_access_hash)
    puts JSON.generate({'num_of_total_access' => @access_log.sort_in_num_of_access_order_by(order, each_day_access_hash)})

    each_day_access_hash = Hash.new
    each_day_log_hash.each { | day, log_data_list | each_day_access_hash.store(day, @access_log.get_unique_access_log_list(log_data_list).size) }
    @access_log.sort_in_num_of_access_order_by(order, each_day_access_hash)
    puts JSON.generate({'num_of_unique_access' => @access_log.sort_in_num_of_access_order_by(order, each_day_access_hash)})
  end
  
  # print_each_data_access - 各データごとのアクセス数を出力する
  #--------------------------------------------------------------------
  def print_num_of_each_data_access(data_name)
    each_data_log_hash = Hash.new
    @access_log.get_each_data_log_hash(data_name, @access_log.log_data_list).each { | key, each_log_list | each_data_log_hash.store(key, each_log_list.size) }
    puts JSON.generate({data_name => each_data_log_hash})
  end
  
  # print_filter_data - 特定のログの一覧を出力する
  #--------------------------------------------------------------------
  def print_filter_data(data_name, value)
    each_data_log_hash = @access_log.get_each_data_log_hash(data_name, @access_log.log_data_list)

    if (each_data_log_hash[value])
      print_log(each_data_log_hash[value])
    end
  end

  # print_log - ログの一覧を出力する
  #--------------------------------------------------------------------
  private
  def print_log(log_data_list)
    log_data_list.each do | log |
      puts JSON.generate(log)
    end

  end

end
