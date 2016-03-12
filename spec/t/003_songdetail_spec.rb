require_relative '../rbase'
include Rbase

# テスト用データベース構築
init = proc do
  `zenra init`
  User.create('sa2knight' , 'sa2knight' , 'ないと')
  User.create('tomotin' , 'tomotin' , 'ともちん')
  score_type = {'brand' => 'JOYSOUND' , 'name' => '全国採点'}

  register1 = Register.new(User.new('sa2knight'))
  karaoke_id = register1.create_karaoke(
    '2016-01-05 11:00:00' , '楽曲詳細ページテスト用カラオケ' , 3 ,
    {'name' => 'カラオケ館' , 'branch' => '亀戸店'} ,
    {'brand' => 'JOYSOUND' , 'product' => 'MAX'} ,
  )
  register1.attend_karaoke(1000 , '楽曲詳細ページテスト用attend1')
  register2 = Register.new(User.new('tomotin'))
  register2.karaoke = karaoke_id
  register2.attend_karaoke(1200 , '楽曲詳細ページテスト用attend2')
  
  score1 = [21.6 , 47.3 , 57.1 , 68.3 , 76.2 , 80.9 , 90 , 93.8 , 98.2 , 99.90]
  score2 = [2.4 , 38.5 , 70.2 , 79 , 82.5 , 90.4 , 94.2 , 100 , 100 , 100]
  0.upto(9) do |i|
    register1.create_history('ゼロ' , 'BUMP OF CHICKEN' , 0 , score_type , score1[i])
    register2.create_history('ゼロ' , 'BUMP OF CHICKEN' , 0 , score_type , score2[i])
  end
end

# テスト実行
describe '楽曲詳細ページ' do
  before(:all,&init)
  it '得点の集計が正常に表示されるか' do
    login 'sa2knight'
    visit '/history'
    examine_songlink('ゼロ' , 'BUMP OF CHICKEN')
    examine_text('my_sangcount' , 'あなた: 10')
    examine_text('my_maxscore' , '最高: 99.90')
    examine_text('my_minscore' , '最低: 21.60')
    examine_text('my_avgscore' , '平均: 73.33')
    examine_text('sangcount' , 'みんな: 20')
    examine_text('maxscore' , '最高: 100.00')
    examine_text('minscore' , '最低: 2.40')
    examine_text('avgscore' , '平均: 74.52')
    login 'tomotin'
    visit '/history'
    examine_songlink('ゼロ' , 'BUMP OF CHICKEN')
    examine_text('my_sangcount' , 'あなた: 10')
    examine_text('my_maxscore' , '最高: 100.00')
    examine_text('my_minscore' , '最低: 2.40')
    examine_text('my_avgscore' , '平均: 75.72')
  end
  it 'Youtubeがインラインで表示されているか' do
    login 'sa2knight'
    visit 'history'
    examine_songlink('ゼロ' , 'BUMP OF CHICKEN')
    db = DB.new(:SELECT => 'url' , :FROM => 'song' , :WHERE => 'name = ?' , :SET => 'ゼロ')
    tube = db.execute_column
    expect(youtube_links[0].slice(/\w+$/)).to eq tube.slice(/\w+$/)
  end

  it 'リンクが正常に登録されているか' do
    login 'sa2knight'
    visit 'history'
    examine_songlink('ゼロ' , 'BUMP OF CHICKEN')
    song_url = page.current_path
    examine_karaokelink('楽曲詳細ページテスト用カラオケ' , song_url)
    examine_userlink('ないと' , song_url)
  end

end
