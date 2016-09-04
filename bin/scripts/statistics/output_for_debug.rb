#----------------------------------------------------------------------
# OutputForDebug - 解析結果を日本語表記で標準出力するクラス
#----------------------------------------------------------------------
require_relative 'access_log'

class OutputForDebug
  
  def initialize(access_log)
    @access_log = access_log
  end

  # print - ログの一覧を標準出力する
  #--------------------------------------------------------------------
  def print_log
    @access_log.log_data_list.each do | log |
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
    puts "総アクセス数:   #{@access_log.log_data_list.size}回"
    puts "ユニークアクセス数:   #{@access_log.get_unique_access_log_list(@access_log.log_data_list).size}回"
  end

  # print_num_of_each_day_access - 日ごとの総アクセス数とユニークアクセス数を標準出力する
  #--------------------------------------------------------------------
  def print_num_of_each_day_access
    puts '総アクセス数:'
    @access_log.get_each_day_log_hash(@access_log.log_data_list).each do | day, log_data_list |
      puts "%-20s%s回"%[day, log_data_list.size]
    end
    puts

    puts "ユニークアクセス数:"
    @access_log.get_each_day_log_hash(@access_log.log_data_list).each do | day, log_data_list |
      puts "%-20s%s回"%[day, @access_log.get_unique_access_log_list(log_data_list).size]
    end
  end
  
  # print_num_of_each_data_access - 各データごとのアクセス数を標準出力する
  #--------------------------------------------------------------------
  def print_num_of_each_data_access(data_name)
    each_data_log_hash = @access_log.get_each_data_log_hash(data_name, @access_log.log_data_list)

    puts "#{data_name}の種類ごとのアクセス数"
    each_data_log_hash.each do | key, each_log_list |
      puts "%-40s%s回"%[key, each_log_list.size]
    end
  end

end
