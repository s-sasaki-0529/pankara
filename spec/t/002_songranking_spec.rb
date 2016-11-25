require_relative '../rbase'
include Rbase

# テスト用データベース構築
init = proc do
  `zenra init -d 2016_05_01_17_15`
  `zenra mysql -e 'update song set url = NULL where id = 147'`
end

# 定数定義
url = '/ranking/song'

# テスト実行
describe '楽曲ランキング機能' , :js => true do

  before(:all,&init)
  before do
    login 'sa2knight'
    visit url
  end

  it 'ランキングが正常に表示される' do
    tables = table_to_hash('songranking_table')
    expect(tables.select {|t| t['動画'] == '未登録'}.length).to eq 1
    expect(tables.length).to eq 50
    expect(tables[0]['tostring']).to eq '1,,Hello, world!,BUMP OF CHICKEN,12'
    expect(tables[1]['tostring']).to eq '2,未登録,ray,BUMP OF CHICKEN,10'
  end

  it 'あなたのランキングに切り替え' do
    iscontain 'あなたのランキングへ'
    visit '/ranking/song?showmine=true'
    tables = table_to_hash('songranking_table')
    expect(tables[3]['tostring']).to eq '4,,MISTAKE,ナナホシ管弦楽団,8'
    visit url
    tables = table_to_hash('songranking_table')
    expect(tables[0]['tostring']).to eq '1,,Hello, world!,BUMP OF CHICKEN,12'
  end

  it 'あなたのランキングへの切り替えリンク' do
    iscontain 'あなたのランキングへ'
    logout
    visit url
    islack 'あなたのランキングへ'
  end

  it 'リンクが正常に登録されているか' do
    examine_songlink('ray' , 'BUMP OF CHICKEN' , url)
    examine_artistlink('BUMP OF CHICKEN' , url)
  end
end
