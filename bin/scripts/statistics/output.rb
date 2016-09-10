#----------------------------------------------------------------------
# Output - 解析結果をJSON形式でファイル出力するクラス
#----------------------------------------------------------------------
require 'json'

require_relative 'access_log'

LOGDIR = 'logs/json'

class Output

  def initialize(access_log)
    @access_log = access_log
  end

  # print - ログを出力する
  #--------------------------------------------------------------------
  def print_log
    file = File.open("#{LOGDIR}/log_list.json", "w")

    @access_log.log_data_list.each do | log |
      file.print JSON.generate(log)
    end
  end

  # print_num_of_each_day_access - 日ごとの総アクセス数とユニークアクセス数を出力する
  #--------------------------------------------------------------------
  def print_num_of_each_day_access
    file = File.open("#{LOGDIR}/each_day_access.json", "w")
   
    each_day_log_hash = Hash.new
    @access_log.get_each_day_log_hash(@access_log.log_data_list).each { | day, log_data_list | each_day_log_hash.store(day, log_data_list.size) }
    file.print JSON.generate({'num_of_total_access' => each_day_log_hash})

    each_day_log_hash = Hash.new
    @access_log.get_each_day_log_hash(@access_log.log_data_list).each { | day, log_data_list | each_day_log_hash.store(day, @access_log.get_unique_access_log_list(log_data_list).size) }
    file.print JSON.generate({'num_of_unique_access' => each_day_log_hash})
  end
  
  # print_each_data_access - 各データごとのアクセス数を出力する
  #--------------------------------------------------------------------
  def print_num_of_each_data_access(data_name)
    file = File.open("#{LOGDIR}/each_data_access.json", "w")
    
    each_data_log_hash = Hash.new
    @access_log.get_each_data_log_hash(data_name, @access_log.log_data_list).each { | key, each_log_list | each_data_log_hash.store(key, each_log_list.size) }
    file.print JSON.generate({data_name => each_data_log_hash})
  end

end
