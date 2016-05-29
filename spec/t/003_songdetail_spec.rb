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
  it '得点の集計が正常に表示されるか' do
    examine_songlink('オンリーロンリーグローリー' , 'BUMP OF CHICKEN')
    examine_text('my_sangcount' , 'あなた: 14')
    examine_text('my_maxscore' , '最高: 97.00')
    examine_text('my_minscore' , '最低: 88.39')
    examine_text('my_avgscore' , '平均: 92.65')
    examine_text('sangcount' , 'みんな: 5')
    examine_text('maxscore' , '最高: 97.00')
    examine_text('minscore' , '最低: 93.00')
    examine_text('avgscore' , '平均: 94.60') 
    login 'hetare'
    visit '/history'
    examine_songlink('オンリーロンリーグローリー' , 'BUMP OF CHICKEN')
    examine_text('my_sangcount' , 'あなた: 2')
    examine_text('my_maxscore' , '最高: 97.00')
    examine_text('my_minscore' , '最低: 95.00')
    examine_text('my_avgscore' , '平均: 96.00')
    examine_text('sangcount' , 'みんな: 17')
    examine_text('maxscore' , '最高: 97.00')
    examine_text('minscore' , '最低: 88.39')
    examine_text('avgscore' , '平均: 92.84')
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
