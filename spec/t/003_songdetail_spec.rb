require_relative '../rbase'
include Rbase

# テスト用データベース構築
init = proc do
  `zenra init -d 2016_03_14_21_21`
  `zenra mysql -e 'update history set song = 1 , score_type = 1 where score > 90'`
end

# テスト実行
describe '楽曲詳細ページ' do
  before(:all,&init)
  before do
    login 'sa2knight'
    visit '/history'
  end
  it 'Youtubeがインラインで表示されているか' do
    examine_songlink('オンリーロンリーグローリー' , 'BUMP OF CHICKEN')
    db = DB.new(:SELECT => 'url' , :FROM => 'song' , :WHERE => 'name = ?' , :SET => 'オンリーロンリーグローリー')
    tube = db.execute_column
    expect(youtube_links[0].slice(/\w+$/)).to eq tube.slice(/\w+$/)
  end
  it 'リンクが正常に登録されているか' , :js => true do
    examine_songlink('オンリーロンリーグローリー' , 'BUMP OF CHICKEN')
    song_url = page.current_path
    examine_karaokelink('祝本番環境リリースカラオケ' , song_url)
    examine_userlink('ないと' , song_url)
  end

end
