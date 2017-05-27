require_relative '../rbase'
include Rbase

# テスト用データベース構築
init = proc do
  `zenra init -d 2017_05_24_04_00`
end

# 定数定義
url = '/history/list/sa2knight'

# テスト実行
describe '歌唱履歴ページ' do

  before(:all,&init)
  before { visit url }

  it '表示内容' do
    table = table_to_hash('history_table')
    expect(table.length).to eq 50
    expect(table[0]['tostring']).to eq "1873,2017-05-21,Stage of the ground BUMP OF CHICKEN,Stage of the ground,BUMP OF CHICKEN,0,8"
    expect(table[1]['tostring']).to eq "1872,2017-05-21,flyby BUMP OF CHICKEN,flyby,BUMP OF CHICKEN,0,7"
    expect(table[2]['tostring']).to eq "1871,2017-05-21,メルト supercell,メルト,supercell,0,9"
  end

  it 'リンク' do
    examine_songlink('コノハの世界事情' , 'じん' , url)
    examine_artistlink('Neru' , url)
    link '1854'
    examine_historylink('ないと' , '珍しく昼間に' , '君じゃなきゃダメみたい')
  end

  it 'ページング' do
    visit '?page=38'
    table = table_to_hash('history_table')
    expect(table.length).to eq 23
    expect(table[-5]['tostring']).to eq "5,2016-01-03,PONPONPON きゃりーぱみゅぱみゅ,PONPONPON,きゃりーぱみゅぱみゅ,-3,"
    expect(find('#range').text).to eq '1873 曲中 1851 〜 1873 曲目を表示中'
  end

end
