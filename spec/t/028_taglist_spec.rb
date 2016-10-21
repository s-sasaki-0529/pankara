require_relative '../rbase'
include Rbase

# テスト用データベース構築
init = proc do
  `zenra init -d 2016_08_24_04_00`
end

# テスト実行
describe 'タグ一覧機能' do
  before(:all , &init)
  before do
    visit '/search/tag_list'
  end

  it 'タグ検索へのリンク' do
    link_strictly('GUMI')
    iscontain 'タグ "GUMI" が登録された楽曲一覧(35件)'
  end

  it '登録曲数が表示される' do
    tags_table = table_to_hash('taglist_table')
    expect(tags_table[0]['tostring']).to eq 'VOCALOID,120'
    expect(tags_table[1]['tostring']).to eq '初音ミク,65'
    expect(tags_table[2]['tostring']).to eq 'アニソン,62'
  end

  it '全てのタグが表示される' do
    tag_num = `zenra mysql -se "select COUNT(DISTINCT name) from tag"`
    tags_table = table_to_hash('taglist_table')
    expect(tags_table.length).to eq tag_num.to_i
  end
end
