require_relative '../rbase'
include Rbase

# テスト用データベース構築
init = proc do
  `zenra init -d 2016_08_24_04_00`
end

# 楽曲を新規登録
def create_song(song_name , artist_name)
  js('register.createSong();')
  fill_in 'song' , with: song_name
  fill_in 'artist' , with: artist_name
  find('#button1').click
  wait_for_ajax
end

# 指定した楽曲がDBに何曲あるかを検証
def examine_song_num(song_name , expect_num)
  result = `zenra mysql -se "select count(id) from song where name = '#{song_name}'"`
  expect(result.to_i).to eq expect_num
end

# テスト実行
describe '楽曲登録機能' , :js => true do
  before(:all , &init)
  before do
    login 'sa2knight'
  end

  it 'ログインしていないと登録できない' do
    logout
    create_song('アマリリス冒険記' , '少年隊')
    current_path_is '/auth/login'
    examine_song_num('アマリリス冒険記' , 0)
  end

  it '正常登録' do
    create_song('真・からくり屋敷の歌' , 'からくり隊')
    iscontain '真・からくり屋敷の歌 / からくり隊'
    examine_song_num('真・からくり屋敷の歌' , 1)
  end

  it '既存楽曲あり' do
    create_song('天体観測' , 'BUMP OF CHICKEN')
    iscontain '天体観測 / BUMP OF CHICKEN'
    examine_song_num('天体観測' , 1)
  end

  it '楽曲・歌手名未入力' do
    create_song('' , '')
    current_path_is '/'
    examine_song_num('' , 0)
  end

  it '楽曲未入力' do
    create_song('' , 'ハイテンション男')
    current_path_is '/'
    examine_song_num('' , 0)
  end

  it '歌手未入力' do
    create_song('盛岡バンザイ祭歌' , '')
    current_path_is '/'
    examine_song_num('盛岡バンザイ祭歌' , 0)
  end

end
