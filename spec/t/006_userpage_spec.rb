require_relative '../rbase'

include Rbase

# テスト用データベース構築
init = proc do
  `zenra init`
  User.create('unagipai' , 'unagipai' , 'ちゃら')
  score_type = {'brand' => 'JOYSOUND' , 'name' => '全国採点オンライン2'}

  register = Register.new(User.new('unagipai'))
  register.with_url = false
  karaoke_id = register.create_karaoke(
    '2015-12-26 20:00:00' , 'ユーザページテスト用カラオケ1' , 3 ,
    {'name' => 'カラオケ館' , 'branch' => '盛岡店'} ,
    {'brand' => 'JOYSOUND' , 'product' => 'MAX'} ,
  )
  register.attend_karaoke(1500 , 'ユーザページテスト用attend1')
  register.create_history('千の夜をこえて' ,  'Aqua Timez' , 0 , score_type , 72)
  register.create_history('心絵' , 'ロードオブメジャー' , 0 , score_type , 82)

  karaoke_id = register.create_karaoke(
    '2015-12-28 24:00:00' , 'ユーザページテスト用カラオケ2' , 2 ,
    {'name' => 'カラオケ館' , 'branch' => '盛岡店'} ,
    {'brand' => 'JOYSOUND' , 'product' => 'MAX'} ,
  )
  register.attend_karaoke(1500 , 'ユーザページテスト用attend2')
  register.create_history('決意の朝に' , 'Aqua Timez' , 0 , score_type , 76.3)
  
  karaoke_id = register.create_karaoke(
    '2016-01-01 01:00:00' , 'ユーザページテスト用カラオケ3' , 2 ,
    {'name' => 'カラオケ館' , 'branch' => '盛岡店'} ,
    {'brand' => 'JOYSOUND' , 'product' => 'MAX'} ,
  )
  register.attend_karaoke(1500 , 'ユーザページテスト用attend3')
  register.create_history('つぼみ' , 'Aqua Timez' , 0 , score_type , 59)
  register.create_history('Butter-Fly' , '和田光司' , 0 , score_type , 70)
  
  karaoke_id = register.create_karaoke(
    '2016-01-12 12:00:00' , 'ユーザページテスト用カラオケ4' , 2 ,
    {'name' => 'カラオケ館' , 'branch' => '盛岡店'} ,
    {'brand' => 'JOYSOUND' , 'product' => 'MAX'} ,
  )
  register.attend_karaoke(1500 , 'ユーザページテスト用attend4')
  register.create_history('Butter-Fly' , '和田光司' , 0 , score_type , 80)
  
  karaoke_id = register.create_karaoke(
    '2013-12-26 20:00:00' , 'ユーザページテスト用カラオケ5' , 2 ,
    {'name' => 'カラオケ館' , 'branch' => '盛岡店'} ,
    {'brand' => 'JOYSOUND' , 'product' => 'MAX'} ,
  )
  register.attend_karaoke(1500 , 'ユーザページテスト用attend5')
  register.create_history('夏空' , 'ガリレオガリレイ' , 0 , score_type , 76)
end

# 定数定義
url = '/user/unagipai'

# テスト実行
describe 'ユーザページ機能' do
  before(:all,&init)
  it '最近のカラオケが正常に表示されるか' do
    # 対象テーブルがN行存在することを検証する
    # 1つ以上の行をサンプリングして、内容を検証する
    login 'unagipai'
    visit url
    karaoke_table = table_to_hash('recent_karaoke')
    
    expect(karaoke_table.length).to eq 5
    expect(karaoke_table[0]['tostring']).to eq '2016-01-12 12:00:00,ユーザページテスト用カラオケ4'
  end
  it '最近歌った曲が正常に表示されるか' do
    # 対象テーブルがN行存在することを検証する
    # 1つ以上の行をサンプリングして、内容を検証する
    login 'unagipai'
    visit url
    karaoke_table = table_to_hash('recent_sang')
    
    expect(karaoke_table.length).to eq 5
    expect(karaoke_table[0]['tostring']).to eq 'Butter-Fly,和田光司'
  end
  it '各種集計が正常に表示されるか' do
    # 一番歌ってる曲が正常に表示される
    # 一番歌っている歌手が正常に表示される
    # 最高得点が正常に表示される
    login 'unagipai'
    visit url
    
    iscontain 'Butter-Fly / 和田光司 / 2回'
    iscontain 'Aqua Timez / 3回'
    iscontain '82.0 / 心絵 / ロードオブメジャー / 採点方法: 全国採点オンライン2'
  end
  it 'リンクが正常に登録されているか' , :js => true do
    login 'unagipai'
    visit url
    id_to_element('recent_karaoke').find('tbody').all('tr')[0].click #最近のカラオケ一行目をクリックし、Javascriptで画面遷移
    # 最近のカラオケにリンクが登録されていることを検証する
    # 最近歌った曲の曲名にリンクが登録されていることを検証する
    # 最近歌った曲の歌手名にリンクが登録されていること検証する
    # 一番歌っている曲の曲名にリンクが登録されていることを検証する
    # 一番歌っている曲の歌手名にリンクが登録されていることを検証する
    # 一番歌っている歌手の歌手名にリンクが登録されていることを検証する
    # 最高得点の曲名にリンクが登録されていることを検証する
    # 最高得点の歌手名にリンクが登録されていることを検証する
  end
end
