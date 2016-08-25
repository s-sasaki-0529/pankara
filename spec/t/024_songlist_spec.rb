require_relative '../rbase'
include Rbase

# テスト用データベース構築
init = proc do
  `zenra init -d 2016_08_24_04_00`
end

def ex_record(ex)
  expect(table_to_hash('song_list_table')[0]['tostring']).to eq ex
end

URL = '/user/songlist/sa2knight'

# テスト実行
describe '集計情報表示機能' , :js => true do
  
  before(:all , &init)
  before do
    login 'sa2knight'
    visit URL
  end
  
  describe '各種リンク' do
    it '曲名' do
      examine_songlink('ライアーダンス' , 'DECO*27')
    end
    it '歌手名' do
      examine_artistlink('高槻やよい')
    end
    it '最終歌唱日' do
      page.all('.lastSangKaraoke')[1].click
      expect(page.all('h3')[0].text).to eq '盆休み最終日カラオケ'
    end
  end

  describe 'ページング' do
    it '次へ' do
      all('#pager_next_page > a')[0].click
      ex_record ',アンパンマンのマーチ ドリーミング 歌唱回数: 1 最終歌唱日: 2016-08-23,,チェリー スピッツ 歌唱回数: 7 最終歌唱日: 2016-08-23'
    end
    it '前へ' do
      visit URL + '?page=8'
      all('#pager_prev_page > a')[0].click
      ex_record ',beautiful flower 美郷あき 歌唱回数: 3 最終歌唱日: 2016-06-11,,鳥の詩 Lia 歌唱回数: 1 最終歌唱日: 2016-06-11'
    end
    it '最後へ' do
      all('#pager_last_page > a')[0].click
      ex_record ',月光 鬼束ちひろ 歌唱回数: 1 最終歌唱日: 2016-01-17,,ダイヤモンド BUMP OF CHICKEN 歌唱回数: 1 最終歌唱日: 2016-01-03'
    end
    it '先頭へ' do
      all('#pager_first_page > a')[0].click
      ex_record ',月光花 Janne Da Arc 歌唱回数: 1 最終歌唱日: 2016-08-23,,紅蓮の弓矢 Linked Horizon 歌唱回数: 1 最終歌唱日: 2016-08-23'
    end
    it '特定のページヘ' do
      all('#pager_page_10 > a')[0].click
      ex_record ',sailing day BUMP OF CHICKEN 歌唱回数: 1 最終歌唱日: 2016-05-01,,バトルクライ BUMP OF CHICKEN 歌唱回数: 1 最終歌唱日: 2016-04-23'
    end
    it '表示件数変更' do
      ex1 = ',すろぉもぉしょん ピノキオP 歌唱回数: 12 最終歌唱日: 2016-08-23,,ゴーストルール DECO*27 歌唱回数: 15 最終歌唱日: 2016-08-23'
      ex2 = ',Ending BUMP OF CHICKEN 歌唱回数: 3 最終歌唱日: 2016-08-17,,マジLOVE2000% ST☆RISH 歌唱回数: 1 最終歌唱日: 2016-08-17'
      expect(table_to_hash('song_list_table').length).to eq 24 / 2 - 1
      expect(table_to_hash('song_list_table')[-1]['tostring']).to eq ex1
      visit URL + '?pagenum=72'
      expect(table_to_hash('song_list_table').length).to eq 72 / 2 - 1
      expect(table_to_hash('song_list_table')[-1]['tostring']).to eq ex2
    end
  end

  #describe '検索' do
  #  it '曲名' do
  #  end
  #  it '歌手名' do
  #  end
  #  it 'タグ' do
  #  end
  #  it 'ヒット無し' do
  #  end
  #end

  #describe '並び順' do
  #  it '最後に歌った日' do
  #  end
  #  it '初めて歌った日' do
  #  end
  #  it '歌唱回数' do
  #  end
  #  it '曲名' do
  #  end
  #  it '歌手名' do
  #  end
  #  it '昇順' do
  #  end
  #  it '降順' do
  #  end
  #end

end
