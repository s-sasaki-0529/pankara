require_relative '../rbase'
include Rbase

# テスト用データベース構築
init = proc do
  `zenra init -d 2016_05_18_04_00`
end

# 定数定義
url = '/history/sa2knight'

# テスト実行
describe '歌唱履歴ページ' do

  before(:all,&init)
  before { visit url }

  it '表示内容' do
    table = table_to_hash('history_table')
    expect(table.length).to eq 50
    expect(table[0]['tostring']).to eq "405,2016-05-15,オリオンをなぞる UNISON SQUARE GARDEN,オリオンをなぞる,UNISON SQUARE GARDEN,0"
    expect(table[1]['tostring']).to eq "404,2016-05-15,桜 コブクロ,桜,コブクロ,0"
    expect(table[2]['tostring']).to eq "403,2016-05-15,君という名の翼 コブクロ,君という名の翼,コブクロ,0"
  end

  it 'リンク' do
    examine_songlink('ロミオとシンデレラ' , 'doriko' , url)
    examine_artistlink('BUMP OF CHICKEN' , url)
  end

  it 'ページング' do
    visit '?page=9'
    table = table_to_hash('history_table')
    expect(table.length).to eq 5
    expect(table[0]['tostring']).to eq "5,2016-01-03,PONPONPON きゃりーぱみゅぱみゅ,PONPONPON,きゃりーぱみゅぱみゅ,-3"
  end

end
