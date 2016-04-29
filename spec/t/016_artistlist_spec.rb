require_relative '../rbase'
include Rbase

# テスト用データベース構築
init = proc do
  `zenra init -d 2016_04_29_04_00`
end

# テスト実行

url = '/artist_list'

describe '歌手一覧ページ' do
  before(:all,&init)
  before do
    login 'sa2knight'
    visit url
  end

  it 'アーティスト一覧が正常に表示されるか' do
    tables = table_to_hash('artistlist_table')
    expect(tables.length).to eq 199
    expect(tables[0]['tostring']).to eq 'BUMP OF CHICKEN,23'
    expect(tables[7]['tostring']).to eq 'Supercell,4'
  end

  it 'リンクが正常に登録されているか' do
    artists = ['BUMP OF CHICKEN' , '遠藤正明' , '放課後ティータイム']
    artists.each do |artist|
      examine_artistlink artist , url
    end
  end
end
