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
      ex_record ',ふわふわ時間 放課後ティータイム 歌唱回数: 1 最終歌唱日: 2016-08-17,,PERFECT HUMAN RADIO FISH 歌唱回数: 1 最終歌唱日: 2016-07-23'
    end
    it '前へ' do
      visit URL + '?page=8'
      all('#pager_prev_page > a')[0].click
      ex_record ',パンダヒーロー ハチ 歌唱回数: 1 最終歌唱日: 2016-04-16,,BLOOM OF YOUTH オーイシマサヨシ 歌唱回数: 1 最終歌唱日: 2016-04-16'
    end
    it '最後へ' do
      all('#pager_last_page > a')[0].click
      ex_record ',オンリーロンリーグローリー BUMP OF CHICKEN 歌唱回数: 2 最終歌唱日: 2016-01-30,,ダイヤモンド BUMP OF CHICKEN 歌唱回数: 1 最終歌唱日: 2016-01-03'
    end
    it '先頭へ' do
      all('#pager_first_page > a')[0].click
      ex_record ',月光花 Janne Da Arc 歌唱回数: 1 最終歌唱日: 2016-08-23,,紅蓮の弓矢 Linked Horizon 歌唱回数: 1 最終歌唱日: 2016-08-23'
    end
    it '特定のページヘ' do
      all('#pager_page_3 > a')[0].click
      ex_record ',ベストピクチャー BUMP OF CHICKEN 歌唱回数: 1 最終歌唱日: 2016-06-11,,脳漿炸裂ガール れるりり 歌唱回数: 1 最終歌唱日: 2016-06-11'
    end
    it '表示件数変更' do
      ex1 = ',炉心融解 iroha 歌唱回数: 1 最終歌唱日: 2016-08-17,,マジLOVE2000% ST☆RISH 歌唱回数: 1 最終歌唱日: 2016-08-17'
      ex2 = ',海の声 浦島太郎 歌唱回数: 1 最終歌唱日: 2016-05-28,,隣に・・・ 三浦あずさ 歌唱回数: 1 最終歌唱日: 2016-05-28'
      expect(table_to_hash('song_list_table')[-1]['tostring']).to eq ex1
      visit URL + '?pagenum=72'
      expect(table_to_hash('song_list_table')[-1]['tostring']).to eq ex2
    end
  end

  describe '検索' do
    it '曲名' do
      ex = ',Stage of the ground BUMP OF CHICKEN 歌唱回数: 1 最終歌唱日: 2016-05-05,,The Biggest Dreamer 和田光司 歌唱回数: 1 最終歌唱日: 2016-03-26'
      visit URL + '?filter_category=song&filter_word=the'
      expect(find('#range').text()).to eq '5 曲表示中'
      ex_record ex
    end
    it '歌手名' do
      ex = ',続・くだらない唄 BUMP OF CHICKEN 歌唱回数: 1 最終歌唱日: 2016-06-27,,くだらない唄 BUMP OF CHICKEN 歌唱回数: 1 最終歌唱日: 2016-06-27'
      visit URL + '?filter_category=artist&filter_word=BUMP+OF+CHICKEN'
      expect(find('#range').text()).to eq '40 曲中1~24曲目を表示中'
      ex_record ex
    end
    it 'タグ' do
      ex = ',初音ミクの消失 cosMo@暴走P 歌唱回数: 1 最終歌唱日: 2016-08-23,,炉心融解 iroha 歌唱回数: 1 最終歌唱日: 2016-08-17'
      visit URL + '?filter_category=tag&filter_word=VOCALOID'
      expect(find('#range').text()).to eq '111 曲中1~24曲目を表示中'
      ex_record ex
    end
    it 'ヒット無し' do
      visit URL + '?filter_category=tag&filter_word=HOGEFUGA'
      expect(find('#range').text()).to eq '楽曲が見つかりません'
    end
  end

  describe '並び順' do
    it '最後に歌った日' do
      ex = ',月光花 Janne Da Arc 歌唱回数: 1 最終歌唱日: 2016-08-23,,紅蓮の弓矢 Linked Horizon 歌唱回数: 1 最終歌唱日: 2016-08-23'
      visit URL + '?sort_category=last_sang_datetime'
      ex_record ex
    end
    it '初めて歌った日' do
      ex = ',月光花 Janne Da Arc 歌唱回数: 1 最終歌唱日: 2016-08-23,,紅蓮の弓矢 Linked Horizon 歌唱回数: 1 最終歌唱日: 2016-08-23'
      visit URL + '?sort_category=first_sang_datetime'
      ex_record ex
    end
    it '歌唱回数' do
      ex = ',ゴーストルール DECO*27 歌唱回数: 15 最終歌唱日: 2016-08-23,,1/3の純情な感情 SIAM SHADE 歌唱回数: 15 最終歌唱日: 2016-07-23'
      visit URL + '?sort_category=sang_count'
      ex_record ex
    end
    it '曲名' do
      ex = ',高音厨音域テスト 木村ワイP 歌唱回数: 1 最終歌唱日: 2016-06-04,,青春アミーゴ 修二と彰 歌唱回数: 1 最終歌唱日: 2016-08-23'
      visit URL + '?sort_category=song_name'
      ex_record ex
    end
    it '歌手名' do
      ex = ',月光 鬼束ちひろ 歌唱回数: 1 最終歌唱日: 2016-01-17,,残酷な天使のテーゼ 高橋洋子 歌唱回数: 2 最終歌唱日: 2016-06-18'
      visit URL + '?sort_category=artist_name'
      ex_record ex
    end
    it '昇順に変更' do
      ex = ',はなまるぴっぴはよいこだけ A応P 歌唱回数: 1 最終歌唱日: 2016-01-03,,SIX SAME FACES イヤミ、おそ松、カラ松、チョロ松、一松、十四松、トド松 歌唱回数: 1 最終歌唱日: 2016-01-03'
      visit URL + '?sort_category=last_sang_datetime&sort_order=asc'
      ex_record ex
    end
  end

  describe '共通の持ち歌' do
    it 'ログインなし' do
      visit '/auth/logout'
      visit URL
      islack 'あなたと共通の持ち歌のみ'
    end

    it '自分の持ち歌ページ' do
      visit URL
      islack 'あなたと共通の持ち歌のみ'
    end

    it '共通の持ち歌あり' do
      visit '/user/songlist/unagipai?common=on'
      iscontain 'あなたと共通の持ち歌のみ'
      iscontain '17 曲表示中'
      iscontain ['もう恋なんてしない' , '女々しくて' , 'Butter-Fly']
    end

    it '共通の持ち歌なし' do
      visit '/user/songlist/worry?common=on'
      iscontain 'あなたと共通の持ち歌のみ'
      iscontain '楽曲が見つかりません'
    end
  end

  it '検索条件のリセット' do
    visit URL
    url1 = current_url
    click_on '表示'
    expect(url1 == current_url).to eq false
    click_on 'リセット'
    expect(url1 == current_url).to eq true
  end

  describe '歌唱履歴に追加' do
    def f (mode = 0)
      visit '/user/songlist/sa2knight'
      js("zenra.addHistoryToRecentKaraoke({idx: '0'})")
      if mode == 1
        click_on '終了';
      end
      if mode == 2
        click_on '登録'; wait_for_ajax
        click_on '終了';
        visit '/karaoke/recent'
      end
      wait_for_ajax
    end
    it '曲名/歌手名が自動入力される' do
      f()
      expect(find('#song').value()).to eq 'ライアーダンス'
      expect(find('#artist').value()).to eq 'DECO*27'
    end
    it '登録ダイアログを閉じてもリダイレクトしない' do
      f(1)
      expect(current_path).to eq '/user/songlist/sa2knight'
    end
    it '前回のカラオケに登録される' do
      f(2)
      history = table_to_hash('karaoke_detail_history_1')
      expect(history[-1]['tostring']).to eq '44,ないと,,ライアーダンス,DECO*27,5,,,'
    end
    it 'ログインしていないとアイコンが表示されない' do
      cant_find('.songlist-add-icon')
    end
  end

end
