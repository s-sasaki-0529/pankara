require_relative '../rbase'
include Rbase

# テスト用データベース構築
init = proc do
  `zenra init -d 2016_08_24_04_00`
end

def create_song(song_name , artist_name)
  js('register.createSong();')
  song_name.nil? or fill_in 'song' , with: song_name
  artist_name.nil? or fill_in 'artist' , with: artist_name
  wait_for_ajax
end

def create_karaoke(name)
  js('register.createKaraoke();')
  fill_in 'store', with: name
  wait_for_ajax
end

# テスト実行
describe '楽曲登録機能' , :js => true do
  before(:all , &init)
  before do
    login 'sa2knight'
  end

  describe '曲名のもしかしてリスト' do

    it '入力１文字では反応なし' do
      create_song('天' , nil)
      islack ['天体観測']
    end

    it '２文字以上で候補を表示' do
      create_song('天体' , nil)
      iscontain '天体観測'
    end

    it '候補が複数曲ある場合' do
      create_song('愛の' , nil)
      iscontain ['愛のうた' , 'ダ・カーポⅢ ~君にささげる愛の魔法~']
    end

    it '歌手名が入力された場合に候補を表示' do
      create_song(nil , '中島みゆき')
      fill_in 'song' , with: ''
      iscontain ['地上の星' , '命の別名' , '糸' , '空と君とのあいだに' , '銀の龍の背に乗って']
    end

  end

  describe '歌手名のもしかしてリスト' do

    it '入力1文字では反応なし' do
      create_song(nil , 'B')
      islack 'BUMP OF CHICKEN'
    end

    it '2文字以上で候補を表示' do
      create_song(nil , 'BUMP')
      iscontain 'BUMP OF CHICKEN'
    end

    it '候補が複数ある場合' do
      create_song(nil , 'of')
      iscontain ['BUMP OF CHICKEN' , 'ALL OF' , 'FENCE OF DEFENSE' , 'FIELD OF VIEW']
    end

    it '歌手名が入力された場合に即入力' do
      create_song('nil' , nil)
      fill_in 'song' , with: '天体観測'; wait_for_ajax
      js("$('#artist').focus();")
      expect(evaluate_script("$('#artist').val()")).to eq 'BUMP OF CHICKEN'
    end

  end

  describe '店名/店舗名のもしかしてリスト' do

    it '入力1文字では反応なし' do
      create_karaoke('館')
      islack 'カラオケ館'
    end

    it '2文字以上で候補を表示' do
      create_karaoke('歌広')
      iscontain '歌広場'
    end

    it '候補が複数ある場合' do
      create_karaoke('カラオケ')
      iscontain ['カラオケ館' , 'カラオケの鉄人']
    end

    it '店舗名の候補を出す' do
      create_karaoke('カラオケ館')
      #Todo 未実装. 実装後テストを追加する
    end

  end

end
