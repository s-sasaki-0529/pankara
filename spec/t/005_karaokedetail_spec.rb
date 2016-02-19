require_relative '../rbase'
include Rbase

# テスト用データベース構築
init = proc do
  `zenra init`
  User.create('sa2knight' , 'sa2knight' , 'ないと')
  User.create('tomotin' , 'tomotin' , 'ともちん')
  score_type = {'brand' => 'JOYSOUND' , 'name' => '全国採点'}

  register = Register.new(User.new('sa2knight'))
  register.with_url = false
  karaoke_id = register.create_karaoke(
    '2016-01-05 12:00:00' , 'カラオケ詳細ページテスト用カラオケ' , 5 ,
    {'name' => 'カラオケ館' , 'branch' => '亀戸店'} ,
    {'brand' => 'JOYSOUND' , 'product' => 'MAX'} ,
  )
  register.attend_karaoke(1500 , 'カラオケ詳細ページテスト用attend1')
  register.create_history('プラネタリウム' ,  'BUMP OF CHICKEN' , 0 , score_type , 72)
  register.create_history('真っ赤な空を見ただろうか' , 'BUMP OF CHICKEN' , 0 , score_type , 92.3)
  register.create_history('ハルジオン' , 'BUMP OF CHICKEN' , 0 , score_type , 59)

  register = Register.new(User.new('tomotin'))
  register.with_url = false
  register.karaoke = karaoke_id
  register.attend_karaoke(1200 , 'カラオケ詳細ページテスト用attend2')
  register.create_history('メーデー' , 'BUMP OF CHICKEN' , 0 , score_type , 91)
  register.create_history('ダイヤモンド' , 'BUMP OF CHICKEN' , 0 , score_type , 80)
  register.create_history('ベンチとコーヒー' , 'BUMP OF CHICKEN' , 0 , score_type , 87)

end

# 定数定義
url = '/karaoke/detail/1'

# テスト実行
describe 'カラオケ詳細ページ' do
  before(:all,&init)
  it 'カラオケ概要が正常に表示されるか' do
    login 'sa2knight'
    visit url
    iscontain 'カラオケ詳細ページテスト用カラオケ'
    des_table = table_to_hash('karaoke_detail_description')
    expect(des_table[0]['tostring']).to eq '2016-01-05 12:00:00,5.0,カラオケ館 亀戸店,JOYSOUND(MAX),ないと ともちん'
  end
  it '歌唱履歴が正常に表示されるか' do
    login 'sa2knight'
    visit url
    history_table = table_to_hash('karaoke_detail_history')
    expect(history_table.length).to eq 6
    expect(history_table[0]['tostring']).to eq 'ないと,未登録,プラネタリウム,BUMP OF CHICKEN,0,全国採点,72.0'
    expect(history_table[3]['tostring']).to eq 'ともちん,未登録,メーデー,BUMP OF CHICKEN,0,全国採点,91.0'
  end
  it 'リンクが正常に登録されているか' do
    login 'sa2knight'
    visit url
    examine_userlink('ないと' , url)
    examine_userlink('ともちん' , url)
    examine_songlink('メーデー' , 'BUMP OF CHICKEN' , url)
    examine_artistlink('BUMP OF CHICKEN' , url)
  end
end
