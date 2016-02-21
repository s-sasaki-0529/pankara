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
history = {
  'song' => '心絵',
  'artist' => 'ロードオブメジャー',
  'score_type' => 'JOYSOUND 全国採点',
  'score' => 80
}

# テスト実行
describe '履歴入力用ダイアログのテスト', :js => true do
  before(:all , &init)
 
  before do
    login 'unagipai'
    page.all('a' , :text => 'カラオケを記録する')[0].click
    click_link 'カラオケを新規登録'
  end

  it 'ダイアログが正常に表示されるか' do
    iscontain karaoke_contents
  end

  it 'ダイアログの画面が正常に遷移されるか' do
    input_karaoke
    click_button '次へ' 
    iscontain history_contents
  end

  it '入力内容が正しく登録されるか' do
    input_karaoke
    click_button '次へ'
   
    input_history_with_data history, 1
   
    input_history 1
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
    
    history = [
      'ちゃら',
      'song1',
      'artist1',
      '0',
      '全国採点',
      '1.0'
    ]
    iscontain history
  end

  it '20件登録されるか' do
    input_karaoke
    click_button '次へ'
   
    19.times do |i|
      input_history (i + 1), (i + 1)
    end

    input_history 20
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
      'song20',
      'artist20',
      '0',
      '全国採点',
      '20.0'
    ]
    iscontain history
  end

end
