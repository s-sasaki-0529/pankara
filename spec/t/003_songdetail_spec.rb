require_relative '../rbase'
include Rbase

# テスト用データベース構築
init = proc do
  `zenra init -d 2016_06_13_00_24`
end

# テスト実行
describe '楽曲詳細ページ' , :js => true do
  before(:all,&init)

  describe '歌唱回数グラフ' do
  end

  describe '採点結果グラフ' do
  end

  describe 'Youtubeプレイヤー' do
  end

  describe '歌唱履歴' do
    # 現在は022_song_tag_spec.rbにて個別に実施
  end

  describe 'リンク' do
  end

end
