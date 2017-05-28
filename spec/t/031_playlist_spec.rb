require_relative '../rbase'
include Rbase

# テスト用データベース構築
init = proc do
  `zenra init -d 2016_10_17_02_57`
end

# テスト実行
describe 'プレイリスト機能' , :js => true do

  before(&init) #一部のテストでDBを買い替えているので、毎回初期化する
  
  def normal(url)
    visit url
    iscontain '動画を連続再生する'
    link_strictly '動画を連続再生する'
    iscontain '再生リスト'
  end

  def abnormal(url)
    visit url
    islack '再生リスト'
  end

  describe 'プレイリストへのリンク' do
    describe '持ち歌一覧' do
      it '正常系' do
        normal '/user/songlist/sa2knight'
      end
      it '異常系' do
        abnormal '/user/songlist/test'
      end
    end
    describe '歌唱履歴' do
      it '正常系' do
        normal '/history/list/sa2knight'
      end
      it '異常系' do
        abnormal '/history/list/test'
      end
    end
    describe 'アーティスト詳細画面' do
      it '正常系' do
        normal '/artist/86'
      end
    end
    describe 'カラオケ詳細画面' do
      it '正常系' do
        normal '/karaoke/detail/90'
      end
    end
    describe 'タグ検索結果' do
      it '正常系' do
        normal '/search/tag/?tag=VOCALOID'
      end
      it '異常系' do
        abnormal '/search/tag/?tag=hogehoge'
      end
    end
    describe '楽曲ランキング' do
      it '正常系' do
        normal '/ranking/song'
      end
    end
    describe '得点ランキング' do
      it '正常系' do
        normal '/ranking/score'
      end
    end
  end

  describe 'プレイリストの生成' do
    it '全ての楽曲がリストに含まれている' do
      visit '/history/list/worry'
      history_num = page.all('.history-table').count
      link '動画を連続再生'
      iscontain '再生リスト(19曲)'
      playlist_num = table_to_array('playlist_tabel_main').count
      expect(history_num).to eq playlist_num
    end
    it '楽曲が重複している場合ユニークに' do
      visit '/history/list/sa2knight'
      history_num = page.all('.history-table').map {|h| h.all('td')[3].text}.uniq.count
      link '動画を連続再生'
      iscontain '再生リスト(22曲)'
      playlist_num = table_to_array('playlist_tabel_main').count
      expect(history_num).to eq playlist_num
    end
    it '動画の存在しない楽曲は除外される' do
      `zenra mysql -e "update song set url = NULL where id < 50"`
      visit '/history/list/worry'
      link '動画を連続再生'
      iscontain '再生リスト(12曲)'
      playlist_num = table_to_array('playlist_tabel_main').count
      expect(playlist_num).to eq 12
    end
    it '順番をシャッフルする' do #奇跡が起こってシャッフル前後で並び順が同じになった場合、テストは落ちる
      visit '/history/list/worry'
      link '動画を連続再生'
      names1 = table_to_array('playlist_tabel_main').map {|p| p[2]}.join(',')
      link '順番をシャッフル'
      names2 = table_to_array('playlist_tabel_main').map {|p| p[2]}.join(',')
      expect(names1 == names2).to eq false
    end
  end
end

