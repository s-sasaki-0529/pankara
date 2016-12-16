require_relative '../rbase'
include Rbase

# テスト用データベース構築
init = proc do
  `zenra init -d 2016_12_14_04_00`
end

# テスト実行
describe 'ランキング' do
  before(:all , &init)
  before do
    login 'sa2knight'
  end
  def examine(table_name , row , string)
    table = table_to_hash(table_name)
    expect(table[row]['tostring']).to eq string
  end
  describe '楽曲ランキング' do
    url = '/ranking/song'
    table_name = 'songranking_table'
    it '全体の' do
      visit url
      examine(table_name , 49 , '50,弱虫モンブラン DECO*27,弱虫モンブラン,DECO*27,9')
    end
    it 'あなたの' do
      visit "#{url}?showmine=1"
      examine(table_name , 49 , '50,からくりピエロ 40mP,からくりピエロ,40mP,7')
    end
    it '重複を含まない' do
      visit "#{url}?distinct=1"
      examine(table_name , 49 , '50,MAD HEAD LOVE 米津玄師,MAD HEAD LOVE,米津玄師,8')
    end
    it '重複を含まないあなたの' do
      visit "#{url}?showmine=1&distinct=1"
      examine(table_name , 49 , '50,ピエロ KEI,ピエロ,KEI,6')
    end
    it 'リンク' do
      visit url
      examine_songlink('ブリキノダンス' , '日向 電工' , url)
      examine_artistlink('BUMP OF CHICKEN')
    end
  end
  describe '歌手ランキング' do
    table_name = 'artistranking_table'
    url = '/ranking/artist'
    it '全体の' do
      visit url
      examine(table_name , 49 , '50,風鳴翼,13,5,2.60')
    end
    it 'あなたの' do
      visit "#{url}?showmine=1"
      examine(table_name , 49 , '50,放課後ティータイム,7,6,1.17')
    end
    it '重複を含まない' do
      visit "#{url}?distinct=1"
      examine(table_name , 49 , '50,malo,10,1,10.00')
    end
    it '重複を含まないあなたの' do
      visit "#{url}?showmine=1&distinct=1"
      examine(table_name , 49 , '50,放課後ティータイム,6,6,1.00')
    end
    it 'リンク' do
      visit url
      examine_artistlink 'BUMP OF CHICKEN'
    end
  end
  describe '得点ランキング' do
    url = '/ranking/score'
    table_name = 'scoreranking_table'
    it '全体のランキング' do
      visit url
      examine(table_name , 19 , '20,YUME日和 島谷ひとみ,2016-05-05,ないと,YUME日和 (島谷ひとみ),90.23,')
    end
    it 'あなたのランキング' do
      visit "#{url}?showmine=1"
      examine(table_name , 19 , '20,ray BUMP OF CHICKEN,2016-03-12,ないと,ray (BUMP OF CHICKEN),89.99,')
    end
    it '採点モード切り替え' do
      visit "#{url}?score_type=7"
      examine(table_name , 19 , '20,LOVEマシーン モーニング娘。,2016-03-05,ちゃら,LOVEマシーン (モーニング娘。),89.00,')
    end
    it '採点モードを切り替えてあなたのランキング' do
      visit "#{url}?score_type=7&showmine=1"
      examine(table_name , 19 , '20,さよならのかわりに、花束を 花束P,2016-03-05,ないと,さよならのかわりに、花束を (花束P),75.00,')
    end
  end
end
