#----------------------------------------------------------------------
# Util - 汎用ライブラリ
#----------------------------------------------------------------------
require_relative 'db'
require 'uri'
require 'open-uri'
require 'json'
require 'yaml'
#require 'searchbing'
CONFIG = 'config.yml'
SECRET = '../secret.yml'
class Util

  @@request = nil
  @@run_mode = nil

  # Const - 定数管理
  #---------------------------------------------------------------------
  module Const
    class Friend
      FRIEND = 3
      FOLLOW = 2
      FOLLOWED = 1
      NONE = 0
    end
  end

  # set_request - セション情報を設定
  #--------------------------------------------------------------------
  def self.set_request(request)
    @@request = request
  end

  # url - URLを生成する
  #---------------------------------------------------------------------
  def self.url(*path)
    url = "http://#{@@request.host}"
    if @@request.port != 80
      url += ":#{@@request.port}"
    end
    path.each do |p|
      url += "/#{p}"
    end
    return url
  end

  # icon_file - ユーザ名を指定し、アイコンファイルのパスを取得する
  #----------------------------------------------------------------------
  def self.icon_file(username)
    user_icon = "/image/user_icon/#{username}.png"
    sample_icon = "/image/sample_icon.png"
    File.exist?("app/public/#{user_icon}") ? user_icon : sample_icon
  end

  # search_image - 画像をbing画像検索より取得
  #---------------------------------------------------------------------
  def self.search_image(word , opt = {})
    apikey = Util.read_secret('bingsearch_api_key')
    bing = Bing.new(apikey , 1 , 'Image')
    result = bing.search(word)
    if opt[:thumbnail]
      result[0][:Image][0][:Thumbnail][:MediaUrl]
    else
      result[0][:Image][0][:MediaUrl]
    end
  end

  # search_tube - 曲名と歌手名を指定し、Youtube動画のURLを取得する
  #----------------------------------------------------------------------
  def self.search_tube(song , artist)
    # テスト実行時は取得しない
    Util.run_mode == 'ci' and return nil

    # youtubeにアクセスし、「曲名 歌手名」で検索した1件目を取得
    word = "#{song} #{artist}"
    uri = URI.escape("https://www.youtube.com/results?search_query=#{word}")
    html = open(uri) do |f|
      charset = f.charset
      f.read
    end
    html.scan(%r|"/watch\?v=(\w+?)"|) do
      return "https://www.youtube.com/watch?v=#{$1}"
    end

    # 取得失敗時、歌手名を省略して再検索。それでもダメならnilを戻す
    if artist == ""
      return nil
    else
      return self.search_tube(song , "")
    end
  end

  # read_file - 指定したYAMLファイルを参照する
  #--------------------------------------------------------------------
  def self.read_file(file , key)
    data = YAML.load_file(file)
    data[key]
  end

  # write_file - 指定したYAMLファイルに書き込む
  #--------------------------------------------------------------------
  def self.write_file(file , key , val)
    data = YAML.load_file(file)
    if val
      data[key] = val
    else
      data.delete(key)
    end
    open(file , "w"){|f| f.write(YAML.dump(data))}
  end

  # read_secret - シークレット(gitで共有しない)情報を参照する
  #--------------------------------------------------------------------
  def self.read_secret(key)
    Util.read_file(SECRET , key)
  end

  # write_secret - シークレット(gitで共有しない)情報を参照する
  #--------------------------------------------------------------------
  def self.write_secret(key , value)
    Util.write_file(SECRET , key , value)
  end

  # read_config - コンフィグを参照する
  #---------------------------------------------------------------------
  def self.read_config(key)
    Util.read_file(CONFIG , key)
  end

  # set_config - コンフィグを設定する
  #---------------------------------------------------------------------
  def self.set_config(key , value)
    Util.write_file(CONFIG , key , value)
  end

  # to_json - RubyオブジェクトをJSONに変換する
  #---------------------------------------------------------------------
  def self.to_json(data)
    data.kind_of?(Hash) or data.kind_of?(Array) or return ""
    JSON.generate(data)
  end

  # to_hash - JSON文字列をRubyオブジェクトに変換する
  #--------------------------------------------------------------------
  def self.to_hash(json)
    JSON.parse(json)
  end

  # unset_config - コンフィグを削除する
  #---------------------------------------------------------------------
  def self.unset_config(key)
    set_config(key , nil)
  end

  # make_questions - SQLで用いる"? , ? , ?" みたいなのを生成する
  #---------------------------------------------------------------------
  def self.make_questions(num)
    q = '?' * num
    q.split('').join(',')
  end

  # array_to_hash - Array[Hash]をHash[Hash]に変換する
  #---------------------------------------------------------------------
  def self.array_to_hash(array , key)
    hash = {}
    array.each do |i|
      hash[i[key]] = i
    end
    return hash
  end

  # run_mode - 現在のrun modeを取得
  #--------------------------------------------------------------------
  def self.run_mode
    if @@run_mode.nil?
      @@run_mode = Util.read_config('run_mode')
    end
    @@run_mode
  end

  # error - エラーメッセージを返却する
  # RubyハッシュかJSONを選べるが、デフォルトはJSON
  #---------------------------------------------------------------------
  def self.error(mes , type = 'json')
    e = {:result => 'error' , :info => mes}
    if type == 'json'
      Util.to_json(e)
    else
      e
    end
  end

  # write_log - ログを生成する
  #---------------------------------------------------------------------
  def self.write_log(type , log)
    filepath = {
      'sql' => 'logs/sql.log',
      'event' => 'logs/event.log',
    }[type] or return
    datetime = Time.now.strftime("%Y-%m-%d %H:%M:%S")

    File.open(filepath , 'a') do |f|
      f.puts "[#{datetime}] #{log}"
    end
  end

  # debug - 標準出力
  #--------------------------------------------------------------------
  def self.debug(v)
    require 'pp'
    puts "\n---debug---"
    pp v
    puts "-----------"
  end
end
