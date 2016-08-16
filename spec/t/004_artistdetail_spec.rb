require_relative '../rbase'
include Rbase

# テスト用データベース構築
init = proc do
  `zenra init -d 2016_03_14_21_21`
  `zenra mysql -e "update song set artist = 1 where id > 100"`
  `zenra mysql -e "update song set url = NULL where id = 115"`
end

# テスト実行
describe '歌手詳細ページ' , :js => true do
  before(:all,&init)
  before do
    login 'sa2knight'
    visit '/history'
  end

  describe 'Wikipediaが正常に読み込まれるか' do
    it '記事が存在する' do
    end
    it '記事が存在しない' do
    end
  end

  describe 'よく歌われる楽曲グラフ' do
    it 'その他あり' do
    end
    it 'その他なし' do
    end
  end

  describe '歌唱回数グラフ' do
    it '一人だけ歌っている' do
    end
    it '複数人が歌っている' do
    end
  end

  it '歌手の楽曲一覧が正常に表示されるか' do
    examine_artistlink 'BUMP OF CHICKEN'
    tables = table_to_hash('artistdetail_table')
    expect(tables.length).to eq 174
    expect(tables[0]['tostring']).to eq ',オンリーロンリーグローリー,2,0'
    expect(tables[18]['tostring']).to eq '未登録,たったひとつの日々,0,2'
  end

  it 'リンクが正常に登録されているか' do
    visit '/history'
    examine_artistlink('BUMP OF CHICKEN')
    url = page.current_url
    songs = ['走れ' , '君に届け' , 'ロミオとシンデレラ']
    songs.each do |song|
      examine_songlink(song , 'BUMP OF CHICKEN' , url)
    end
  end
end
