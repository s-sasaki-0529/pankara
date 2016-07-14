require_relative '../rbase'
include Rbase

# テスト用データベース構築
init = proc do
  `zenra init`
  User.create('unagipai' , 'unagipai' , 'ちゃら')
end

# 定数定義
karaoke_contents = [
  'カラオケ新規作成',
  'カラオケ名',
  '日時',
  '時間',
  '店',
  '店舗',
  '機種',
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
    click_on '次へ'
    iscontain history_contents
  end

  it '入力内容が正しく登録されるか' do
    input_karaoke
    click_on '次へ'
   
    input_history_with_data history_data, 1
    click_on '登録して終了'; wait_for_ajax
    
    karaoke = [
      '2016-02-20',
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

  it '歌唱回数が正しく表示されるか' do
    input_karaoke
    click_on '次へ'

    3.times do |i|
      input_history 1234 , 4567
      click_on '続けて登録'
      iscontain "song1234(artist4567)を登録しました。"
      iscontain "あなたがこの曲を歌うのは #{i + 1} 回目です。"
    end
  end

  #it '入力された件数が正しく表示されるか' do
  #  input_karaoke
  #  click_on '次へ'
  #
  #  3.times do |i|
  #    input_history i
  #    click_on '続けて登録'
  #    iscontain "#{i + 1}件入力されました"
  #    wait_for_ajax
  #  end
  #end
  
  it '20件登録されるか' do
    input_karaoke
    click_on '次へ'

    20.times do |i|
      input_history i
      click_on '続けて登録'
      wait_for_ajax
    end

    click_on '登録して終了'
  
    histories = []
    20.times do |i|
      histories.push "song#{i}"
      histories.push "artist#{i}"
    end
    iscontain histories
  end
end
