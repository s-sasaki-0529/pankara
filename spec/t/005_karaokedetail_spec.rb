require_relative '../rbase'
include Rbase

# テスト用データベース構築
init = proc do
  `zenra init -d 2016_03_13_22_01`
  `zenra mysql -e "update song set url = '' where id = 7"`
end

# 定数定義
url = '/karaoke/detail/8'
song = {'1' => 'Hello, world!' , '3' => 'シャイン' , '5' => '決意の朝に'}

# テスト実行
describe 'カラオケ詳細ページ' do
  before(:all,&init)
  before do
    login 'sa2knight'
    visit url
  end
  it 'カラオケ概要が正常に表示されるか' do
    iscontain '祝本番環境リリースカラオケ'
    des_table = table_to_hash('karaoke_detail_description')
    expect(des_table[0]['tostring']).to eq '2016-03-05,7.0,カラオケの鉄人 銀座店,その他(その他),75,,'
  end
  it 'タブの切り替えができるか' , :js => true do
    find('#tab_all').click
    iscontain(song.values)
    ['1' , '3' , '5'].each do |i|
      find("#tab_#{i}").click
      wait_for_ajax
      iscontain song[i]
      islack song.select {|n| n != i}.keys
    end
    #col_table = table_to_hash('karaoke_member_table')
    #expect(col_table.length).to eq 3
    #expect(col_table[0]['tostring']).to eq 'ないと,1600,25,97.00,81.57,へたれとちゃらさんと３人で,'
    #expect(col_table[1]['tostring']).to eq 'へたれ,1600,23,97.00,82.50,緊張するんじゃあ,'
    #expect(col_table[2]['tostring']).to eq 'ちゃら,1600,27,94.00,77.25,久しぶり！,'
  end
  it '集計が正常に表示されるか' , :js => true do
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
  it '歌唱履歴が正常に表示されるか' do
    history_table_all = table_to_hash('karaoke_detail_history_all')
    history_table_5 = table_to_hash('karaoke_detail_history_5')
    expect(history_table_all.length).to eq 75
    expect(history_table_5.length).to eq 27
    expect(history_table_all[0]['tostring']).to eq '1,ないと,,Hello, world!,BUMP OF CHICKEN,0,,,'
    expect(history_table_5[1]['tostring']).to eq '2,ちゃら,,はなまるぴっぴはよいこだけ,A応P,0,,,'
  end
  it 'リンクが正常に登録されているか' do
    examine_userlink('ないと' , url)
    examine_userlink('へたれ' , url)
    examine_userlink('ちゃら' , url)
    examine_songlink('Dragon Night' , 'SEKAI NO OWARI' , url)
    examine_artistlink('サイキックラバー' , url)
  end
  describe 'Attendnace情報の変更' , :js => true do
    it '値段を書き換える' do
      find('#tab_1').click
      iscontain '1600 円'
      find('#price_1').click
      wait_for_ajax
      fill_in 'price' , with: '1234567'
      click_on '保存'
      wait_for_ajax
      find('#tab_1').click
      islack '1600 円'
      iscontain '1234567 円'
    end
    it '感想を書き換える' do
      find('#tab_1').click
      iscontain 'へたれとちゃらさんと３人で'
      find('#memo_1').click
      wait_for_ajax
      fill_in 'memo' , with: '変更後のメモ'
      click_on '保存'
      wait_for_ajax
      find('#tab_1').click
      islack 'へたれとちゃらさんと３人で'
      iscontain '変更後のメモ'
    end
  end
  describe '歌唱履歴を追加登録できるか' do
    it '参加済みユーザで登録' do
    end
    it '未参加ユーザで登録' do
    end
  end
end
