#----------------------------------------------------------------------
# Util - 汎用ライブラリ
#----------------------------------------------------------------------
require_relative 'db'
require 'date'
require 'uri'
require 'open-uri'
require 'json'
require 'yaml'
require 'wikipedia'
require 'gmail'
require 'fastimage'
require 'digest/md5'
#require 'searchbing'

MAILADDR = 'pandarin.karaoke@gmail.com'
CONFIG = 'config.yml'
SECRET = '../secret.yml'
PUBLIC = 'app/public'
UPDATES = 'updates.json'
IMGDIR = "#{PUBLIC}/image"
ICONDIR = "#{IMGDIR}/user_icon"
YOUTUBE = "https://www.youtube.com"
class Util

  @@session = nil
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
    class Maintenance
      ACCEPT = 2
      CLOSE = 1
      OPEN = 0
    end
    class Twitter
      Messages = [
        'ツイートに成功しました' ,
        'ツイッター連携が確認できませんでした。連携状態を確認してください',
        'ツイッターAPIが凍結しています。管理者にお問い合わせください',
        '文字数がオーバーしたためツイートに失敗しました',
        'ツイートに失敗しました'
      ]
    end
  end

  # set_request - リクエスト情報を設定
  #--------------------------------------------------------------------
  def self.set_request(request)
    @@request = request
  end

  # request - リクエスト情報を取得
  #--------------------------------------------------------------------
  def self.request
    @@request
  end

  # set_session - セション情報を設定
  #--------------------------------------------------------------------
  def self.set_session(session)
    @@session = session
  end

  # modify_session - セションの一部内容を上書きする
  #--------------------------------------------------------------------
  def self.modify_session(key , value)
    @@session[key] = value
  end

  # session - セション情報を取得
  #--------------------------------------------------------------------
  def self.session
    @@session
  end

  # write_access_log - アクセスログを生成する
  #--------------------------------------------------------------------
  def self.write_access_log(user)
    @@request.path.scan(/\./).empty? or return  #静的ファイルへのアクセスは除外
    username = user.nil? ? '' : user['username']
    params = []
    params.push(@@request.ip)
    params.push(username)
    params.push(@@request.path)
    params.push(@@request.referrer)
    params.push(@@request.device_type)
    params.push(@@request.os)
    params.push(@@request.browser)
    params.push(@@request.request_method)
    Util.write_log('request' , params.join(','))
  end

  # is_smartphone - アクセスがスマートフォンかどうかを戻す
  # クライアントがスマートフォンでもPCページを希望する場合は真を戻す
  #--------------------------------------------------------------------
  def self.is_smartphone?
    return @@request.device_type == :smartphone && ! @@session['view_pc_mode']
  end

  # is_smartphoen_strictly - アクセスがスマートフォンかどうかを戻す
  # クライアントがPCページを希望する場合も、端末がスマートフォンの場合真を戻す
  #--------------------------------------------------------------------
  def self.is_smartphone_strictly?
    return @@request.device_type == :smartphone
  end

  # is_pc - アクセスがPCかどうかを戻す(スマートフォンでなければ全てPCとする)
  #--------------------------------------------------------------------
  def self.is_pc?
    return ! Util.is_smartphone?
  end

  # maintenance_status - 現在メンテナンス中かを取得
  #---------------------------------------------------------------------
  def self.maintenance_status
    mt = Util.read_config('maintenance')
    if mt && mt != ""
      if mt == @@request.ip
        return Util::Const::Maintenance::ACCEPT
      else
        return Util::Const::Maintenance::CLOSE
      end
    end
    return Util::Const::Maintenance::OPEN
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

  # add_get_params - 現在のURLにGETパラメータを付与する
  #--------------------------------------------------------------------
  def self.add_get_params(params)
    url = @@request.url.dup
    params.each do |k,v|
      if url.index('?').nil?
        url += "?#{k}=#{v}"
      elsif url.index("#{k}=")
        url.gsub!(/#{k}=\w+/ , "#{k}=#{v}")
      else
        url += "&#{k}=#{v}"
      end
    end
    return url
  end

  # get_get_param - 現在のURLのGETパラメータを取得する
  #----------------------------------------------------------------------
  def self.get_get_param(key)
    url = @@request.url.dup
    matched = url.scan(/#{key}=(.+?)(&.+|$)/)
    return matched.empty? ? '' : matched[0][0]
  end

  # send_mail - メールを送信する
  # 送信元/送信先はpandarin.karaoke@gmail.com で固定
  #----------------------------------------------------------------------
  def self.send_mail(title , body , opt = {})
    Util.run_mode == 'ci' and return true
    gmail = Gmail.new(MAILADDR, Util.read_secret('mail_pw'))
    message =
      gmail.generate_message do
        from "\"パンダリンのカラオケランド\" <#{MAILADDR}>"
        to MAILADDR
        subject title
        html_part do
          content_type "text/html; charset=UTF-8"
          body body
        end
      end
    gmail.deliver(message)
    gmail.logout
  end

  # icon_file - ユーザ名を指定し、アイコンファイルのパスを取得する
  #----------------------------------------------------------------------
  def self.icon_file(username)
    user_icon = "/image/user_icon/#{username}.png"
    user_icon_mtime = Util.filemtime(user_icon)
    sample_icon = "/image/sample_icon.png"
    if File.exist?("#{ICONDIR}/#{username}.png")
      return "#{user_icon}?#{user_icon_mtime}"
    else
      sample_icon
    end
  end

  # create_user_icon - サンプルユーザアイコンを指定したユーザに適用する
  #--------------------------------------------------------------------
  def self.create_user_icon(username)
    if File.exists? "#{ICONDIR}/#{username}.png"
      return false
    else
      FileUtils.cp("#{IMGDIR}/sample_icon.png" , "#{ICONDIR}/#{username}.png")
    end
  end

  # save_icon_file - 画像ファイルとユーザ名を指定し、アイコンファイルを上書きする
  # Todo: これがUtilにあってメッセージを戻すのはさすがにおかしい。Iconクラスあったほうがいいかも
  #--------------------------------------------------------------------
  def self.save_icon_file(image , username)
    accept_type = ['image/jpg' , 'image/jpeg' , 'image/png' , 'image/gif']
    type = image[:type]
    file = image[:tempfile]
    if accept_type.include?(type)
      filepath = "#{ICONDIR}/#{username}.png"
      tmppath = "#{ICONDIR}/#{username}?.png"
      File.open(tmppath , 'wb') do |f|
        f.write file.read
      end
      size = FastImage.size(tmppath)
      FileUtils.move(tmppath , filepath)
      # 横幅が96px以上なら縮小する
      if size[0] > 255
        `convert -geometry 255 #{filepath} #{filepath}`
      end
    else
      return "アップロードできるファイルは、jpg/png/gifのみです"
    end
    return 'アイコンファイルを変更しました'
  end

  # get_wikipedia - 指定したワードでWikipedia検索する
  #--------------------------------------------------------------------
  def self.get_wikipedia(word , opt = {})
    Wikipedia.Configure {
      domain 'ja.wikipedia.org'
      path   'w/api.php'
    }
    page = Wikipedia.find(word)
    if page.content
      return page
    else
      return false
    end
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
    uri = URI.escape("#{YOUTUBE}/results?search_query=#{word}")
    html = open(uri) do |f|
      charset = f.charset
      f.read
    end
    html.scan(%r|"/watch\?v=(\w+?)"|) do
      return $1
    end

    # 取得失敗時、歌手名を省略して再検索。それでもダメならnilを戻す
    if artist == ""
      return nil
    else
      return self.search_tube(song , "")
    end
  end

  # youtube_to_id - YoutubeのURLから動画IDを抜き出す
  #---------------------------------------------------------------------
  def self.youtube_to_id(url)
    if url =~ %r|www.youtube.com/watch\?v=(.+)$|
      return $1
    else
      return false
    end
  end

  # login_url - ログインページヘのURLを生成する
  #--------------------------------------------------------------------
  def self.login_url
    path = @@request.path
    if path == '/auth/login'
      return path
    else
      return "/auth/login?callback=#{path}"
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

  # write_secret - シークレット(gitで共有しない)情報に書き込む
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

  # read_update_info - 更新情報ファイルを参照する
  #--------------------------------------------------------------------
  def self.read_update_info
    updates_json = File.open(UPDATES).read
    JSON.parse(updates_json)
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

  # monthly_array - 2016/01から現在月までのデータを管理するための配列を戻す
  # ex) [{:month => '2016-01'} , {:month => '2016-02'} ...]
  def self.monthly_array(opt = {})
    monthly = []
    date = Date.new(2016 , 1 , 1)
    today =  Date.today
    while date <= today
      month = date.strftime('%Y-%m')
      monthly.push :month => month
      date = date >> 1
    end
    opt[:desc] and monthly.reverse!
    monthly
  end

  # create_monthly_data - 月ごとの歌唱回数グラフ用のデータを生成する
  #--------------------------------------------------------------------
  def self.create_monthly_data(sang_histories)
    monthly_data = Util.monthly_array(:desc => true)
    monthly_data.each do |m|
      month = m[:month]
      sang_histories[month] and sang_histories[month].each do |u|
        screen_name = u['user_screenname']
        m[screen_name] or m[screen_name] = 0
        m[screen_name] += 1
      end
      m[:_month] = m[:month]
      m.delete(:month)
    end
    return monthly_data
  end

  # date_diff - ２つの日付の日数差を求める
  # to/fromは、下記のフォーマットに従った日時を表す文字列
  #---------------------------------------------------------------------
  def self.date_diff(to , from)
    format = '%Y-%m-%d %H:%M:%S'
    diff = DateTime.strptime(to , format) - DateTime.strptime(from , format)
    return diff.to_i
  end

  # make_questions - SQLで用いる"? , ? , ?" みたいなのを生成する
  #---------------------------------------------------------------------
  def self.make_questions(num)
    q = '?' * num
    q.split('').join(',')
  end

  # array_to_hash - Array[Hash]をHash[Hash]に変換する
  #---------------------------------------------------------------------
  def self.array_to_hash(array , key , delete = false)
    hash = {}
    array.each do |i|
      hash[i[key]] = i
      delete and i.delete(key)
    end
    return hash
  end

  # filemtime - 指定したファイルの最終更新日時を戻す
  #--------------------------------------------------------------------
  def self.filemtime(filepath)
    file = File::stat("#{PUBLIC}/#{filepath}")
    file.mtime.to_i.to_s
  end

  # url_with_filemtime - 指定したファイルパスに、更新日時を付与して戻す
  #--------------------------------------------------------------------
  def self.url_with_filemtime(filepath)
    mtime = Util.filemtime(filepath)
    return "#{filepath}?#{mtime}"
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
    type == 'json' ? Util.to_json(e) : e
  end

  # md5digest - 文字列をmd5でハッシュ化した文字列を戻す
  #---------------------------------------------------------------------
  def self.md5digest(text)
    Digest::MD5.hexdigest(text)
  end

  # write_log - ログを生成する
  #---------------------------------------------------------------------
  def self.write_log(type , log)
    filepath = {
      'request' => 'logs/request.log',
      'sql' => 'logs/sql.log',
      'event' => 'logs/event.log',
    }[type] or return
    datetime = Time.now.strftime("%Y-%m-%d %H:%M:%S")

    File.open(filepath , 'a') do |f|
      f.puts "#{datetime},#{log}"
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
