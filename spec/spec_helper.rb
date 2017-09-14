# テストカバレッジを実行
require 'simplecov'
SimpleCov.start do
  # 外部ライブラリ、テストコード、アクセス解析機能、ツイッター機能はカバレッジ対象外に
  add_filter "/vendor/"
  add_filter "/spec/"
  add_filter "app/controllers/stat_route.rb"
  add_filter "app/models/twitter.rb"
end

require 'capybara/rspec'
require 'capybara-webkit'
require 'headless'
require 'tilt/erb'
require_relative '../app/controllers/index_route'

RSpec.configure do |config|
  
  # テストに失敗した時点で以降のテストを行わない
  config.fail_fast = true

  # 実行順に依存したテストを排除するために、テスト順をランダムに
  config.order = "random"

  # JavaScript対応のために、仮想ディスプレイを構築
  # Xvfb: X window systemの仮想ディスプレイを構築するソフトウェア
  config.before :suite do
    ENV['DISPLAY'] = 'localhost:1.0'
    system "Xvfb :1 -screen 0 1024x768x16 -nolisten inet6 &"
    system "sleep 1s"
  end
  config.after :suite do
    system "killall Xvfb"
    system "sleep 1s"
  end
  
  # ブラウザの挙動のシミュレートにCapybaraを用いる
  config.include Capybara::DSL          #Capybaraを使うことを宣言
  Capybara.app = Rack::Builder.parse_file("config.ru").first
  Capybara.javascript_driver = :webkit  #HTMLレンダリングにはwebkitを用いる
  Capybara.default_max_wait_time = 10   #最大待ち時間は10秒
  Capybara::Webkit.configure do |c|
    c.block_unknown_urls                #GETに失敗した際のエラーメッセージを抑制
  end                                   #Youtubeのサムネイル取得に失敗することが多々あるため
end
