require_relative '../rbase'
include Rbase

# テスト用データベース構築
init = proc do
  `zenra init -d 2016_06_13_00_24`
  `zenra mysql -e 'update song set url = NULL where id = 2'`
end

# テスト実行
describe '楽曲詳細ページ' , :js => true do
  before(:all,&init)

  describe '歌唱回数グラフ' do
    it '誰も歌っていない楽曲' do
    end
    it '一人のユーザのみ歌っている楽曲' do
    end
    it '複数のユーザが歌っている楽曲' do
    end
  end

  describe '採点結果グラフ' do
    it '採点モードの切り替え' do
    end
    it '採点記録がない場合' do
    end
    it '自分の採点記録のみある場合' do
    end
    it '自分と他のユーザの採点記録がある場合' do
    end
  end

  describe 'Youtubeプレイヤー' do
    it 'URLが登録されている場合' do
      visit '/song/1'
      url = DB.new(:SELECT => 'url' , :FROM => 'song' , :WHERE => 'name = ?' , :SET => 'オンリーロンリーグローリー').execute_column
      expect(youtube_links[0].slice(/\w+$/)).to eq url.slice(/\w+$/)
    end
    it 'URLが登録されていない場合' do
      visit '/song/2'
      iscontain 'Youtubeプレイヤー用のURLが未設定です'
    end
  end

  describe '歌唱履歴' do
  end

  describe 'タグ' do
    #現在は022_song_tag_spec.rbにて個別対応
  end

  describe 'リンク' do
    it '歌手名' do
      visit '/song/38'
      examine_artistlink '164'
    end
    it 'ユーザ名' do
      visit '/song/39'
      examine_userlink 'ウォーリー'
    end
    it 'カラオケ' do
      visit '/song/40'
      examine_karaokelink '免許更新をなかった事にして'
    end
  end

end
