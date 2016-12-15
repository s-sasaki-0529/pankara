require_relative '../rbase'
include Rbase

# テスト用データベース構築
init = proc do
  `zenra init -d 2016_11_03_16_53`
end

# 定数定義
url = '/ranking/artist'

# テスト実行
describe '楽曲ランキング機能' do

  before(:all,&init)
  before do
    login 'sa2knight'
    visit url
  end

  it 'ランキングが正常に表示される' do
    tables = table_to_hash('artistranking_table')
    expect(tables.length).to eq 50
    expect(tables[0]['tostring']).to eq '1,BUMP OF CHICKEN,95,43,2.21'
    expect(tables[4]['tostring']).to eq '5,雪音クリス,34,7,4.86'
  end

  it 'リンクが正常に登録されているか' do
    examine_artistlink('BUMP OF CHICKEN' , url)
    examine_artistlink('雪音クリス' , url)
  end

  it 'あなたのランキングへの切り替え' do
    visit "#{url}?showmine=true"
    tables = table_to_hash('artistranking_table')
    expect(tables[4]['tostring']).to eq '5,40mP,29'
  end

end
