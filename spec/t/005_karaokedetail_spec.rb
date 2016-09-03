require_relative '../rbase'
include Rbase

# テスト用データベース構築
init = proc do
  `zenra init -d 2016_05_31_04_00`
  `zenra mysql -e "update song set url = '' where id = 7"`
end

# 定数定義
url = '/karaoke/detail/8'
song = {'1' => 'Hello, world!' , '3' => 'シャイン' , '5' => '決意の朝に'}

# テスト実行
describe 'カラオケ詳細ページ' , :js => true do
  before(:all,&init)
  before do
    login 'sa2knight'
    visit url
  end
  describe '表示内容' do
    it 'カラオケ概要' do
      iscontain '祝本番環境リリースカラオケ'
      des_table = table_to_hash('karaoke_detail_description')
      expect(des_table[0]['tostring']).to eq '2016-03-05,7.0,カラオケの鉄人 銀座店,その他(その他),75,,'
    end
    describe 'タブの切り替え' do
      it 'ヒトカラの場合「全員」タブは表示されない' do
        visit '/karaoke/detail/62'
        islack '全員'
      end
      it '多カラの場合ユーザごとのタブを切り替えられる' do
        iscontain '全員'
        find('#tab_all').click
        iscontain(song.values)
        ['1' , '3' , '5'].each do |i|
          find("#tab_#{i}").click
          wait_for_ajax
          iscontain song[i]
          islack song.select {|n| n != i}.keys
        end
      end
    end
    it '集計/値段/感想' do
      find('#tab_all').click
      expect(find('#sang_count_all').text).to eq '75'
      expect(find('#sang_artist_count_all').text).to eq '64'
      expect(find('#max_score_all').text).to eq '97.00'
      expect(find('#avg_score_all').text).to eq '80.30'
      find('#tab_1').click
      expect(find('#sang_count_1').text).to eq '25'
      expect(find('#sang_artist_count_1').text).to eq '24'
      expect(find('#max_score_1').text).to eq '97.00'
      expect(find('#avg_score_1').text).to eq '81.57'
      expect(find('#price_1').text).to eq '1600'
      expect(find('#memo_1').text).to eq 'へたれとちゃらさんと３人で'
    end
    it '歌唱履歴' do
      history_table_all = table_to_hash('karaoke_detail_history_all')
      find('#tab_5').click
      history_table_5 = table_to_hash('karaoke_detail_history_5')
      expect(history_table_all.length).to eq 75
      expect(history_table_5.length).to eq 27
      expect(history_table_all[0]['tostring']).to eq '1,ないと,,Hello, world!,BUMP OF CHICKEN,0,,,'
      expect(history_table_5[1]['tostring']).to eq '2,ちゃら,未登録,はなまるぴっぴはよいこだけ,A応P,0,,'
    end
    it 'ユーザリンク/楽曲リンク/歌手リンク' do
      examine_userlink('ないと' , url)
      examine_userlink('へたれ' , url)
      examine_userlink('ちゃら' , url)
      examine_songlink('Dragon Night' , 'SEKAI NO OWARI' , url)
      examine_artistlink('サイキックラバー' , url)
    end
  end
  describe 'Attendnaceの編集' do
    it '値段' do
      find('#tab_1').click
      expect(find('#price_1').text).to eq '1600'

      find('#price_1').click; wait_for_ajax
      fill_in 'price' , with: '1234567'
      click_on '保存'; wait_for_ajax
      find('#tab_1').click
      expect(find('#price_1').text).to eq '1234567'

      find('#price_1').click; wait_for_ajax
      fill_in 'price' , with: '1600'
      click_on '保存'; wait_for_ajax
      find('#tab_1').click
      expect(find('#price_1').text).to eq '1600'
    end
    it '感想' do
      old = 'へたれとちゃらさんと３人で'
      find('#tab_1').click
      expect(find('#memo_1').text).to eq old

      js('register.editAttendance(8)')
      fill_in 'memo' , with: '変更後のテキスト'
      click_on '保存'; wait_for_ajax
      find('#tab_1').click
      expect(find('#memo_1').text).to eq '変更後のテキスト'

      js('register.editAttendance(8)')
      fill_in 'memo' , with: old
      click_on '保存'; wait_for_ajax
      find('#tab_1').click
      expect(find('#memo_1').text).to eq old
    end
  end
  it '歌唱履歴登録' , :js => true do
      expect(table_to_hash('karaoke_detail_history_all').length).to eq 75
      js('register.createHistory(8)')
      fill_in 'song' , with: '新しい楽曲'
      fill_in 'artist' , with: '新しい歌手'
      click_on '登録して終了'; wait_for_ajax
      expect(table_to_hash('karaoke_detail_history_all').length).to eq 76
      js('register.editHistory(8 , 906)')
      click_on '削除'; wait_for_ajax
      islack '新しい楽曲'
      expect(table_to_hash('karaoke_detail_history_all').length).to eq 75
  end
end
