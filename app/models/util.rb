#----------------------------------------------------------------------
# Util - 汎用ライブラリ
#----------------------------------------------------------------------
require_relative 'db'
require_relative 'base'
require_relative 'artist'
require_relative 'history'
require_relative 'karaoke'
require_relative 'product'
require_relative 'song'
require_relative 'store'
require_relative 'score_type'
require_relative 'user'
require_relative 'register'
require_relative 'attendance'
require_relative 'friend'
require_relative 'ranking'
require_relative 'validate'
require 'uri'
require 'open-uri'
require 'json'
require 'yaml'
require 'oauth'
CONFIG = 'config.yml'
SECRET = '../secret.yml'
class Util

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

  # icon_file - ユーザ名を指定し、アイコンファイルのパスを取得する
  #----------------------------------------------------------------------
  def self.icon_file(username)
    user_icon = "/image/user_icon/#{username}.png"
    sample_icon = "/image/sample_icon.png"
    File.exist?("app/public/#{user_icon}") ? user_icon : sample_icon
  end

  # search_tube - 曲名と歌手名を指定し、Youtube動画のURLを取得する
  #----------------------------------------------------------------------
  def self.search_tube(song , artist)
    # テスト実行時は取得しない
    config = Util.read_config('run_mode')
    config == 'ci' and return nil

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

  # get_oauth_url - Twitter認証用のURLを生成する
  #--------------------------------------------------------------------
  def self.get_oauth_url(callback)
    twitter_api = Util.read_secret('twitter_api')
    key = twitter_api['key']
    secret = twitter_api['secret']
    consumer = OAuth::Consumer.new(key, secret, :site => "https://twitter.com")
    request_token = consumer.get_request_token(:oauth_callback => callback)
    return request_token.authorize_url
  end

  # read_secret - シークレット(gitで共有しない)情報を参照する
  #--------------------------------------------------------------------
  def self.read_secret(key)
    secret = YAML.load_file(SECRET)
    secret[key]
  end

  # read_config - コンフィグを参照する
  #---------------------------------------------------------------------
  def self.read_config(key)
    config = YAML.load_file(CONFIG)
    config[key]
  end

  # set_config - コンフィグを設定する
  #---------------------------------------------------------------------
  def self.set_config(key , value)
    config = YAML.load_file(CONFIG)
    if value
      config[key] = value
    else
      config.delete(key)
    end
    open(CONFIG , "w"){|f| f.write(YAML.dump(config))}
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
      hash[i[key]].delete(key)
    end
    return hash
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
      'sql' => 'logs/sql.log'
    }[type] or return
    datetime = Time.now.strftime("%Y-%m-%d %H:%M:%S")

    File.open(filepath , 'a') do |f|
      f.puts "---#{datetime}---"
      f.puts log
      f.puts "----------------------"
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
