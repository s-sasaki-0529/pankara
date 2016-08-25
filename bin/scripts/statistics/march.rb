#----------------------------------------------------------------------
# March - アクセスログ解析ツールの処理開始クラス
#----------------------------------------------------------------------
require_relative 'access_log'
require_relative 'option'

Version = '0.1.0'

class March

  # main - アクセスログ解析ツールのMain処理
  #---------------------------------------------------------------------
  def main
    begin
      option = Option.new
    rescue => error
      analyse_argument_error(error)
      return
    end

    access_log = AccessLog.new(perse_log_data)
    print_result(option, access_log)
  end

  # analyse_argument_error - 発生したコマンドライン引数に関するエラーを解析してメッセージを表示する
  #---------------------------------------------------------------------
  private
  def analyse_argument_error(error)
    option = error.message.split(' ')[2]
    
    if error.kind_of? OptionParser::InvalidOption
      STDERR.puts "\"#{option}\"は無効なオプションです。詳細は\"--help\"参照。"
    else
      STDERR.puts "\"#{option}\"オプションに正しい値を指定してください。詳細は\"--help\"参照。"
    end
  end

  # perse_log_data - 標準入力されたアクセスログデータをHashに変換する
  #---------------------------------------------------------------------
  private
  def perse_log_data
    log_data = Array.new
  
    while line = STDIN.gets
      data_name = ['date', 'ip', 'user', 'url', 'referer', 'device', 'os', 'blowser']
      data = line.split(',')
  
      hash = Hash.new
      data_name.each_index do | index |
        hash.store(data_name[index], data[index])
      end
      
      hash['date'] = hash['date'].split(' ')[0]
      hash['blowser'].gsub!(/(\n)/, "")
      
      log_data.push(hash)
    end
  
    return log_data
  end

  # print_result - オプションに応じた結果を出力する
  #---------------------------------------------------------------------
  private
  def print_result(option, access_log)
    from = option.get('from')
    access_log.from(from) if from
    
    to = option.get('to')
    access_log.to(to) if to

    if option.get('cnt')
      if from or to
        access_log.print_num_of_each_day_access
      else
        access_log.print_num_of_access
      end
    elsif agg = option.get('agg')
      access_log.print_each_data_log(agg)
    else
      access_log.print
    end
  end

end

if __FILE__ == $0
  march = March.new
  march.main
end
