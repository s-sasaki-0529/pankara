require_relative '../rbase'

include Rbase

# テスト用データベース構築
init = proc do
  `zenra init`
  User.create('unagipai' , 'unagipai' , 'ちゃら')
  score_type = {'brand' => 'JOYSOUND' , 'name' => '全国採点'}

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
    '2016-12-26 20:00:00' , 'ユーザページテスト用カラオケ5' , 2 ,
    {'name' => 'カラオケ館' , 'branch' => '盛岡店'} ,
    {'brand' => 'JOYSOUND' , 'product' => 'MAX'} ,
  )
  register.attend_karaoke(1500 , 'ユーザページテスト用attend5')
  register.create_history('夏空' , 'Galileo Galilei' , 0 , score_type , 76)
end

# 定数定義
url = '/user/userpage/unagipai'

# テスト実行
describe 'ユーザページ機能' do
  before(:all,&init)
  it '最近のカラオケが正常に表示されるか' do
    login 'unagipai'
    visit url
    karaoke_table = table_to_hash('recent_karaoke_table')

    expect(karaoke_table.length).to eq 5
    expect(karaoke_table[0]['tostring']).to eq '2016-12-26,ユーザページテスト用カラオケ5'
  end
  it '最近歌った曲が正常に表示されるか' do
    login 'unagipai'
    visit url
    karaoke_table = table_to_hash('recent_sang_table')

    expect(karaoke_table.length).to eq 5
    expect(karaoke_table[0]['tostring']).to eq '夏空,Galileo Galilei'
  end
  it '各種集計が正常に表示されるか' do
    login 'unagipai'
    visit url

    most_sang_song_table = table_to_hash('most_sang_song_table')
    expect(most_sang_song_table[0]['tostring']).to eq '2回,Butter-Fly,和田光司'

    #iscontain 'Aqua Timez / 3回' Todo グラフをテスト

    max_score_table = table_to_hash('max_score_table')
    expect(max_score_table[0]['tostring']).to eq '82.00点,心絵,ロードオブメジャー,全国採点'
  end
  it 'リンクが正常に登録されているか' , :js => true do
    login 'unagipai'
    visit url

    id_to_element('recent_karaoke_table').find('tbody').all('tr')[0].click #最近のカラオケ一行目をクリックし、Javascriptで画面遷移
    iscontain 'ユーザページテスト用カラオケ5'
    visit url

    examine_songlink('夏空', 'Galileo Galilei', url)
    examine_artistlink('Galileo Galilei', url)

    examine_artistlink('和田光司', url)

    examine_artistlink('Aqua Timez', url)

    examine_songlink('心絵', 'ロードオブメジャー', url)
    examine_artistlink('ロードオブメジャー', url)
  end
end
