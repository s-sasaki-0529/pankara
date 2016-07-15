require_relative '../rbase'
include Rbase

# テスト用データベース構築
init = proc do
  `zenra init -d 2016_07_13_04_00`
end

# 検索
def search(word , song_num , artist_num , tag_num)
  fill_in 'search_word' , with: word
  click_on '検索'
  
  if word == ''
    iscontain('※検索ワードを入力してから検索ボタンを押してください')
    islack("を含む楽曲一覧")
    islack("を含む歌手一覧")
    islack("を含むタグ一覧")
    return
  end

  if song_num == 0 && artist_num == 0 && tag_num == 0
    iscontain("\"#{word}\" を含む楽曲、歌手、タグが存在しません")
    return
  end

  if song_num > 0
    iscontain("\"#{word}\" を含む楽曲一覧(#{song_num}件)")
    table = table_to_hash('search_song_table')
    expect(table.length).to eq song_num
    table.each do |row|
      match = row['曲名'].match(/#{word}/i)
      expect(match.nil?).to eq false
    end
  else
    islack("を含む楽曲一覧")
  end

  if artist_num > 0
    iscontain("\"#{word}\" を含む歌手一覧(#{artist_num}件)")
    table = table_to_hash('search_artist_table')
    expect(table.length).to eq artist_num
    table.each do |row|
      match = row['歌手名'].match(/#{word}/i)
      expect(match.nil?).to eq false
    end
  else
    islack("を含む歌手一覧")
  end

  if tag_num > 0
  else
    islack("を含むタグ一覧")
  end
end


# テスト実行
describe '楽曲/歌手名検索機能' do
  before(:all , &init)

  before do
    login 'sa2knight'
  end

  describe '検索結果ページ' do
    it '曲＋歌手'  do
      search('光' , 1 , 2 , 0)
      search('of' , 7 , 4 , 0)
      search(' ' , 94 , 35 , 0)
      table = table_to_hash('search_song_table')
      expect(table[0]['tostring']).to eq 'Hello, world!,BUMP OF CHICKEN'
      expect(table[5]['tostring']).to eq 'Bi-Li-Li Emotion,Superfly'
    end

    it '曲のみ' do
      search('メドレー' , 6 , 0 , 1)
      search('song' , 2 , 0 , 0)
    end

    it '歌手のみ' do
      search('雪音' , 0 , 6 , 0)
      search('未来' , 1 , 2 , 0)
    end

    it 'タグ' do
      search('音' , 2 , 7 , 5)
      iscontain(['初音ミク' , '鏡音リン' , '鏡音レン' , '巡音ルカ' , '重音テト'])
    end

    it 'ヒット無し' do
      search('SEKAI GA OWARU' , 0 , 0 , 0)
      search('君が代' , 0 , 0 , 0)
    end

    it '入力なし' do
      search('' , 0 , 0 , 0)
    end

    it 'リンク' do
      search('0' , 3 , 2 , 1)
      url = page.current_url
      examine_songlink 'マジLOVE2000%' , 'ST☆RISH' , url
      examine_artistlink '40mP' , url
      search('VO' , 1 , 0 , 1)
      link 'VOCALOID'
      iscontain 'タグ "VOCALOID" が登録された楽曲一覧(106件)'
    end
  end
  describe 'リダイレクト' do
    it '楽曲' do
      search('世界に一つだけの花' , -1 , -1 , -1)
      expect(current_path).to eq '/song/62'
      iscontain '世界に一つだけの花'
    end

    it 'アーティスト' do
      search('KAT' , -1 , -1 , -1)
      expect(current_path).to eq '/artist/143'
      iscontain 'KAT-TUN'
    end

    it 'タグ' do
      search('VOCALOID' , -1 , -1 , -1)
      iscontain 'タグ "VOCALOID" が登録された楽曲一覧(106件)'
    end
  end

end
