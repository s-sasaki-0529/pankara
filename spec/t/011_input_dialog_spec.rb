require_relative '../rbase'
include Rbase

# テスト用データベース構築
init = proc do
  `zenra init`
  User.create('unagipai' , 'unagipai' , 'ちゃら')
end

# 定数定義
karaoke_contents = [
  'カラオケ入力', 
  'カラオケの新規作成',
  'カラオケ名',
  '日時',
  '時間',
  '店',
  '店舗',
  '機種',
  '値段',
  '感想'
]
history_contents = [
  '曲名', 
  '歌手',
  'キー',
  '採点方法',
  '採点',
]
history_data = {
  'song' => '  心絵   ',
  'artist' => ' ロードオブメジャー',
  'score_type' => 'JOYSOUND 全国採点',
  'score' => 80
}

# テスト実行
describe '履歴入力用ダイアログのテスト', :js => true do
  before(:all , &init)
  after :each do
    wait_for_ajax
  end
  before do
    login 'unagipai'
    js 'register.createKaraoke();'
  end
  
  it 'ダイアログが正常に表示されるか' do
    iscontain karaoke_contents
  end
  
  it 'ダイアログの画面が正常に遷移されるか' do
    input_karaoke
    js 'register.onPushedRegisterKaraokeButton("create");'
    iscontain history_contents
  end

  it '入力内容が正しく登録されるか' do
    input_karaoke
    js 'register.onPushedRegisterKaraokeButton("create");'
   
    input_history_with_data history_data, 1
    js 'register.onPushedRegisterHistoryButton("register");'
    js 'register.onPushedRegisterHistoryButton("end");'
    
    karaoke = [
      '2016-02-20 12:00:00',
      '2.0',
      '歌広場 相模大野店',
      'JOYSOUND(MAX)',
      'ちゃら'
    ]
    iscontain karaoke

    history = [
      'ちゃら',
      '心絵',
      'ロードオブメジャー',
      '0',
      '全国採点',
      '80.0'
    ]
    iscontain history
  end

  it '入力された件数が正しく表示されるか' do
    input_karaoke
    js 'register.onPushedRegisterKaraokeButton("create");'
   
    3.times do |i|
      input_history i
      js 'register.onPushedRegisterHistoryButton("register");'
      iscontain "#{i + 1}件入力されました"
    end
  end
  
  it '20件登録されるか' do
    input_karaoke
    js 'register.onPushedRegisterKaraokeButton("create");'
   
    20.times do |i|
      input_history i
      execute_script 'register.onPushedRegisterHistoryButton("register");'
      wait_for_ajax
    end

    js 'register.onPushedRegisterHistoryButton("end");'
  
    histories = []
    20.times do |i|
      histories.push "song#{i}"
      histories.push "artist#{i}"
    end
    iscontain histories
  end
end
