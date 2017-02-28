require_relative '../rbase'

include Rbase

# テスト用データベース構築
init = proc do
  `zenra init -d 2016_12_28_04_00`
end

# 定数定義
url = '/user/userpage/unagipai'

# テスト実行
describe 'ユーザページ機能' do
  before(:all,&init)
  before do
    login 'unagipai'
    visit url
  end
  it '最近のカラオケが正常に表示されるか' do
    karaoke_table = table_to_hash('recent_karaoke_table')
    expect(karaoke_table.length).to eq 5
    expect(karaoke_table[0]['tostring']).to eq '2016-09-22,夜のOJTとカラオケ'
  end
  it '最近歌った曲が正常に表示されるか' do
    karaoke_table = table_to_hash('recent_sang_table')
    expect(karaoke_table.length).to eq 5
    expect(karaoke_table[0]['tostring']).to eq 'Love So Sweet,嵐,'
    all('.history-link')[1].click
    examine_historylink('ちゃら' , '夜のOJTとカラオケ' , 'Love So Sweet')
  end
  it '友達一覧が正常に表示されるか' do
    friends = table_to_array('users_table')
    expect(friends.length).to eq 5
    expect(friends[0][0]).to eq 'ないと'
    expect(friends[1][0]).to eq 'ともちん'
    expect(friends[2][0]).to eq 'へたれ'
    expect(friends[3][0]).to eq 'にゃんでれ'
    expect(friends[4][0]).to eq 'さっちー'
  end
  it '持ち歌一覧が正常に表示されるか' do
    songlist = table_to_array('user_page_songlist')
    expect(songlist.length).to eq 10
    expect(songlist[0][0]).to eq 'はなまるぴっぴはよいこだけ A応P'
    expect(songlist[1][0]).to eq 'サークルゲーム Galileo Galilei'
    expect(songlist[-1][0]).to eq 'トリセツ 西野かな'
  end
  it '各種集計が正常に表示されるか' do
    #most_sang_song_table = table_to_hash('most_sang_song_table')
    #expect(most_sang_song_table[0]['tostring']).to eq '4回,サークルゲーム,Galileo Galilei'
    max_score_table = table_to_hash('max_score_table')
    expect(max_score_table[0]['tostring']).to eq '94.00点,リンちゃんなう！,オワタP,その他,'
    all('.history-link')[0].click
    examine_historylink('ちゃら' , '祝本番環境リリースカラオケ' , 'リンちゃんなう！')
  end
  it 'リンクが正常に登録されているか' , :js => true do
    id_to_element('recent_karaoke_table').find('tbody').all('tr')[0].click #最近のカラオケ一行目をクリックし、Javascriptで画面遷移
    iscontain %w(2016-09-22 夜のOJTとカラオケ)
    visit url
    examine_songlink('夏空', 'Galileo Galilei', url)
    examine_artistlink('Galileo Galilei', url)
    examine_artistlink('嵐', url)
    examine_artistlink('浦島太郎', url)
    examine_songlink('はなまるぴっぴはよいこだけ', 'A応P', url)
    examine_userlink('ないと' , url)
  end
  describe 'よく歌うアーティストベスト10' , :js => true do
    before do
      login 'unagipai'
      visit url; wait_for_ajax
    end
    it '歌唱履歴が存在する場合' do
      result = ejs("$('#user_sang_artists_chart_json').text();")
      expect(result).to eq '[["Aqua Timez",17.6],["Galileo Galilei",17.6],["放課後ティータイム",13.7],["ロードオブメジャー",7.8],["A応P",7.8],["嵐",7.8],["Base Ball Bear",7.8],["槇原敬之",7.8],["和田光司",5.9],["西野かな",5.9]]'
    end
  end
end
