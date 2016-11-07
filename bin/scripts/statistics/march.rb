#----------------------------------------------------------------------
# March - アクセスログ解析ツールの処理開始クラス
# Copyright (c) 2011 Travis Tilley
# Released under the MIT license
# https://github.com/ttilley/fssm/blob/master/LICENSE
#----------------------------------------------------------------------
require 'date'
require 'fssm'

require_relative 'access_log'
require_relative 'option'
require_relative 'output_for_debug'
require_relative 'output_to_json'

$analysis_flag = true
$end_flag = true

Version = '1.0.0'

class March

  # main - アクセスログ解析ツールのMain処理
  #---------------------------------------------------------------------
  def main
    file_path = ARGV.shift
    @row_count = 0

    begin
      option = Option.new
    rescue => error
      analyse_argument_error(error)
      return
    end

    # followオプションとcnt, aggオプションは同時に指定してはいけない
    if (option.get('follow') && option.get('cnt').nil? && option.get('agg').nil?)
      # 別スレッドでファイルの更新を監視する
      start_file_monitor_thread(file_path)
    
      Signal.trap('INT') { $end_flag = true }

      $end_flag = false
    end

    loop do
      if ($analysis_flag)
        access_log = AccessLog.new(perse_log_data(file_path))
        print_result(option, access_log)

        $analysis_flag = false
      end

      if ($end_flag)
        return
      end

      sleep(0.05)
    end
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
  def perse_log_data(file_path)
    request_file = File.open(file_path) 
    all_request_list = request_file.read.split("\n")
    request_list = all_request_list[@row_count,  all_request_list.count - @row_count]
    
    @row_count = all_request_list.count
    
    log_data = Array.new
    
    request_list.each do | line |
      data_name = ['date', 'ip', 'user', 'url', 'referer', 'device', 'os', 'blowser', 'request']
      data = line.split(',')
  
      hash = Hash.new
      data_name.each_index do | index |
        hash.store(data_name[index], data[index])
      end
    
      hash['request'] = 'GET' unless hash['request']
      log_data.push(hash)
    end
  
    return log_data
  end

  # print_result - オプションに応じた結果を出力する
  #---------------------------------------------------------------------
  private
  def print_result(option, access_log)
    extract_log_by_date(option, access_log)

    output = get_output(option, access_log)
    
    if filter = option.get('filter')
      output.print_filter_data(filter['param'], filter['value'])
    elsif order = option.get('cnt')
      output.print_num_of_each_day_access order
    elsif agg = option.get('agg')
      output.print_num_of_each_data_access(agg)
    else
      output.print_all_log_list
    end
  end

  # extract_log_by_date - 日にちに関するオプションに応じて不要なログを取り除く
  #---------------------------------------------------------------------
  private
  def extract_log_by_date(option, access_log)
    if option.get('today')
      from = Date.today.to_s
      to = from
    else
      from = option.get('from')
      to = option.get('to')
    end
    
    access_log.from(from) if from 
    access_log.to(to) if to
  end

  # get_output - オプションに応じて出力用インスタンスを取得する
  #---------------------------------------------------------------------
  private
  def get_output(option, access_log)
    if option.get('json')
      return OutputToJson.new(access_log)
    else
      return OutputForDebug.new(access_log)
    end
  end

  
  # start_file_monitor_thread - ログファイル監視用スレッドを立ち上げる
  #---------------------------------------------------------------------
  private
  def start_file_monitor_thread(file_path)
    directory, file = File::split(file_path)

    Thread.new do
      begin
      FSSM.monitor(directory, file) do
        update do
          $analysis_flag = true
        end

        delete do | directory, file |
          raise directory + '/' + file + ' has been deleted'
        end
      end
      rescue => error
        puts
        puts error
        $end_flag = true
      end
    end
  end

end

if __FILE__ == $0
  march = March.new
  march.main
end
