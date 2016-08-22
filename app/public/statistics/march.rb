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
    @option = Option.new
    @access_log = AccessLog.new(perse_log_data)

    from = @option.get('from')
    @access_log.from(from) if from
    
    to = @option.get('to')
    @access_log.to(to) if to

    if @option.get('cnt')
      @access_log.print_num_of_access
    else
      @access_log.print
    end
  end

  # perse_log_data - 標準入力されたアクセスログデータをHashに変換する
  #---------------------------------------------------------------------
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

end

if __FILE__ == $0
  march = March.new
  march.main
end
