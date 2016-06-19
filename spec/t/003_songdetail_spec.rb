require_relative '../rbase'
include Rbase

# テスト用データベース構築
init = proc do
  `zenra init -d 2016_06_13_00_24`
  `zenra mysql -e 'insert into song (name , artist) values ("新しい楽曲" , 1)'`
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
      visit '/song/484'
      iscontain 'Youtubeプレイヤー用のURLが未設定です'
    end
  end

  describe '歌唱履歴' do
    it 'タブの切り替え' do
      k1 = '免許更新をなかった事にして'
      k2 = '夜までの時間つぶし'
      login 'sa2knight'
      visit '/song/40'
      iscontain ['あなたの歌唱履歴' , 'みんなの歌唱履歴']
      iscontain k1
      islack k2
      find('#tab-all').click; wait_for_ajax
      iscontain k2
      islack k1
      find('#tab-user').click; wait_for_ajax
      iscontain k1
      islack k2
    end
    it '誰も歌っていない楽曲' do
      visit 'song/484'
      iscontain 'みんなの歌唱履歴'
      iscontain '歌唱履歴がありません'
      islack 'あなたの歌唱履歴'
    end
    it '自分だけが歌っている楽曲' do
      login 'sa2knight'
      visit '/song/147'
      find('#tab-all').click; wait_for_ajax
      iscontain '歌唱履歴がありません'
      find('#tab-user').click; wait_for_ajax
      islack '歌唱履歴がありません'
      history = table_to_hash('song_detail_table_user')
      expect(history.size).to eq 12
      expect(history[9]['tostring']).to eq '2016-02-13,ないととともちん４回目,ないと,-3,JOYSOUND 全国採点,86.66'
    end
    it '他のユーザだけが歌っている楽曲' do
      login 'sa2knight'
      visit '/song/55'
      iscontain 'みんなの歌唱履歴'
      islack 'あなたの歌唱履歴'
      history = table_to_hash('song_detail_table_all')
      expect(history.size).to eq 1
      expect(history[0]['tostring']).to eq '2016-01-08,新年初カラオケ,ウォーリー,0,,'
    end
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
