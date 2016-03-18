require_relative '../rbase'
include Rbase

# テスト用データベース構築
init = proc do
  `zenra init -d 2016_03_14_21_21`
  `zenra mysql -e 'update song set url = NULL where id < 100'`
end

# 定数定義
url = '/ranking/song'

# テスト実行
describe '楽曲ランキング機能' do

  before(:all,&init)
  before do
    login 'sa2knight'
    visit url
  end

  it 'ランキングが正常に表示される' do
    tables = table_to_hash('songranking_table')
    expect(tables.select {|t| t['動画'] == '未登録'}.length).to eq 15
    expect(tables.length).to eq 20
    expect(tables[0]['tostring']).to eq '1,,Hello, world!,BUMP OF CHICKEN,8'
    expect(tables[1]['tostring']).to eq '2,,ray,BUMP OF CHICKEN,6'
    expect(tables[2]['tostring']).to eq '3,未登録,シュガーソングとビターステップ,UNISON SQUARE GARDEN,6'
  end
  it 'リンクが正常に登録されているか' do
    examine_songlink('ray' , 'BUMP OF CHICKEN' , url)
    examine_artistlink('BUMP OF CHICKEN' , url)
  end
end
