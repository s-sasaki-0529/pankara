#----------------------------------------------------------------------
# Option - コマンドライン引数によるオプションの指定を解析するクラス
#----------------------------------------------------------------------
require 'optparse'

class Option

  # initialize - オプションを設定する
  #---------------------------------------------------------------------
  def initialize
    OptionParser.new do |parser|
      @args = Hash.new

      parser.banner = 'Usage: March [--from from] [--to to] [--list | --cnt | --agg [-i | -n | -u | -r | -o | -b | -d]]'
      parser.on('--from=VALUE', '指定した日付を解析するログの下限値に設定する') {|value| @args['from'] = value}
      parser.on('--to=VALUE', '指定した日付を解析するログの上限値に設定する') {|value| @args['to'] = value}
      parser.on('--list', '解析ログの一覧表示') {|v| @args['list'] = v}
      parser.on('--cnt', 'アクセス数の表示') {|v| @args['cnt'] = v}
      parser.on('--agg=VALUE', 
                ['-i', '-n', '-u', '-r', '-o', '-b', '-d'], 
                '指定したオプションに応じたリクエストの集計を行う', 
                "\ti\tIPアドレス別アクセス数", "\tn\tユーザ名別アクセス数",
                "\tu\tURL別アクセス数", "\tr\tリファラ別アクセス数",
                "\to\tOS別アクセス数", "\tb\tブラウザ別アクセス数別",
                "\td\tデバイス別アクセス数") {|value| @args['agg'] = value}

      parser.parse!(ARGV)
    end 
  end

  # get_option - 指定されたオプションを取得する
  #---------------------------------------------------------------------
  def get(option)
    return @args[option]
  end

end
