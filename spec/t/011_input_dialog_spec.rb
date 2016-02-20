require_relative '../rbase'
include Rbase

# テスト用データベース構築
init = proc do
  `zenra init`
  User.create('unagipai' , 'unagipai' , 'ちゃら')
end

# 定数定義
url = '/karaoke/detail/1'
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
  '曲', 
  '歌手',
  'キー',
  '採点方法',
  '採点',
]

# テスト実行
describe '履歴入力用ダイアログのテスト', :js => true do
  before(:all , &init)
  it 'ダイアログが正常に表示されるか' do
    login 'unagipai'
    visit '/'
    page.all('a' , :text => '親メニュー')[0].click
    click_button '入力'

    iscontain karaoke_contents
  end
  it 'ダイアログの画面が正常に遷移されるか' do
    login 'unagipai'
    visit '/'
    page.all('a' , :text => '親メニュー')[0].click
    click_button '入力'

    input_karaoke
    click_button '次へ' 
    
    iscontain history_contents
  end
  it '入力内容が正しく登録されるか' do
    login 'unagipai'
    visit '/'
    page.all('a' , :text => '親メニュー')[0].click
    click_button '入力'

    input_karaoke
    click_button '次へ'
    
    input_history
    click_button '全て登録'

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
end
