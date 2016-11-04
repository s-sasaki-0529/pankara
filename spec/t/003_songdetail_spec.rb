require_relative '../rbase'
include Rbase

# テスト用データベース構築
init = proc do
  `zenra init -d 2016_08_18_07_12`
  `zenra mysql -e 'insert into song (name , artist) values ("新しい楽曲" , 1)'`
end

# 指定したページの歌唱履歴グラフ用JSONを取得
def sang_count_chart(user , song)
  login user
  visit "/song/#{song}"; wait_for_ajax
  json = evaluate_script("$('#sang_count_chart_json').text();")
  info = Util.to_hash(json)
  return Util.array_to_hash(info , '_month' , true)
end

# 指定したページの採点グラフ用JSONを取得
def score_chart(user , song)
  login user
  visit "/song/#{song}"; wait_for_ajax
  json = evaluate_script("$('#score_bar_chart_json').text();")
  scores = Util.to_hash(json)["scores"]
  return Util.array_to_hash(scores , 'name' , true)
end

# テスト実行
describe '楽曲詳細ページ' , :js => true do
  before(:all,&init)

  describe '歌唱回数グラフ' do
    it '誰も歌っていない楽曲' do
      data = sang_count_chart('sa2knight' , 529)
      data.keys.each do |month|
        expect(data[month].empty?).to eq true
      end
    end
    it '一人のユーザのみ歌っている楽曲' do
      data = sang_count_chart('sa2knight' , 147)
      expect(data['2016-08']['ないと']).to eq nil
      expect(data['2016-07']['ないと']).to eq 1
      expect(data['2016-06']['ないと']).to eq 1
      expect(data['2016-05']['ないと']).to eq 3
      expect(data['2016-04']['ないと']).to eq 2
      expect(data['2016-03']['ないと']).to eq 3
      expect(data['2016-02']['ないと']).to eq 4
      expect(data['2016-01']['ないと']).to eq nil
    end
    it '複数のユーザが歌っている楽曲' do
      data = sang_count_chart('sa2knight' , 26)
      expect(data['2016-04'].length).to eq 0
      expect(data['2016-03'].length).to eq 2
      expect(data['2016-02'].length).to eq 1
      expect(data['2016-01'].length).to eq 1
      expect(data['2016-03']['ないと']).to eq 1
      expect(data['2016-03']['ちゃら']).to eq 1
    end
  end

  describe '採点結果グラフ' do
    describe '採点モードの切り替え' do
      mode = [
      'JOYSOUND 分析採点' , 'JOYSOUND その他' ,
      'DAM ランキングバトル' , 'DAM 精密採点' , 'DAM その他' ,
      'その他 その他' , 'JOYSOUND 全国採点'
      ]
      it '右方向' do
        visit '/song/26'; wait_for_ajax
        mode.each do |m|
          all('#score_column > p > img')[1].click; wait_for_ajax
          expect(find('#score_type_name').text).to eq m
        end
      end
      it '左方向' do
        visit '/song/26'; wait_for_ajax
        all('#score_column > p > img')[1].click; wait_for_ajax
        mode.reverse.each do |m|
          all('#score_column > p > img')[0].click; wait_for_ajax
          expect(find('#score_type_name').text).to eq m
        end
      end
    end
    it '採点記録がない場合' do
      data = score_chart('sa2knight' , 200)
      data.values.each do |v|
        expect(v['みんな'].nil?).to eq true
        expect(v['あなた'].nil?).to eq true
      end
    end
    it '自分の採点記録のみある場合' do
      data = score_chart('sa2knight' , 100)
      data.values.each do |v|
        expect(v['みんな'].nil?).to eq true
      end
      expect(data['最低']['あなた']).to eq "81.49"
      expect(data['平均']['あなた']).to eq "85.15"
      expect(data['最高']['あなた']).to eq "88.81"
    end
    it '他のユーザの採点記録のみある場合' do
      data = score_chart('sa2knight' , 144)
      data.values.each do |v|
        expect(v['あなた'].nil?).to eq true
      end
      expect(data['最低']['みんな']).to eq "83.22"
      expect(data['平均']['みんな']).to eq "84.10"
      expect(data['最高']['みんな']).to eq "84.97"
    end
    it '自分と他のユーザの採点記録がある場合' do
      data = score_chart('unagipai' , 7)
      expect(data['最低']['あなた']).to eq "83.02"
      expect(data['平均']['あなた']).to eq "83.02"
      expect(data['最高']['あなた']).to eq "83.02"
      expect(data['最低']['みんな']).to eq "79.47"
      expect(data['平均']['みんな']).to eq "80.85"
      expect(data['最高']['みんな']).to eq "82.22"
    end
  end

  describe 'Youtubeプレイヤー' do
    it 'URLが登録されている場合' do
      visit '/song/1'
      url = DB.new(:SELECT => 'url' , :FROM => 'song' , :WHERE => 'name = ?' , :SET => 'オンリーロンリーグローリー').execute_column
      expect(youtube_links[0].slice(/\w+\?autoplay=0$/)).to eq "#{url.slice(/\w+$/)}?autoplay=0"
    end
    it 'URLが登録されていない場合' do
      visit '/song/529'
      iscontain 'Youtubeプレイヤー用のURLが未設定です'
    end
  end

  describe '歌唱履歴' do
    it 'タブの切り替え' do
      k1 = '免許更新をなかった事にして'
      k2 = '夜までの時間つぶし'
      login 'sa2knight'
      visit '/song/40'
      iscontain ['あなたの' , 'みんなの']
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
      visit 'song/529'
      iscontain 'みんなの'
      iscontain '歌唱履歴がありません'
      islack 'あなたの'
    end
    it '自分だけが歌っている楽曲' do
      login 'sa2knight'
      visit '/song/147'
      find('#tab-all').click; wait_for_ajax
      iscontain '歌唱履歴がありません'
      find('#tab-user').click; wait_for_ajax
      islack '歌唱履歴がありません'
      history = table_to_hash('song_detail_table_user')
      expect(history.size).to eq 14
      expect(history[9]['tostring']).to eq '2016-03-05,祝本番環境リリースカラオケ,ないと,0,その他,85.00'
    end
    it '他のユーザだけが歌っている楽曲' do
      login 'sa2knight'
      visit '/song/55'
      iscontain 'みんなの'
      islack 'あなたの'
      history = table_to_hash('song_detail_table_all')
      expect(history.size).to eq 1
      expect(history[0]['tostring']).to eq '2016-01-08,新年初カラオケ,ウォーリー,0,,'
    end
  end

  describe 'タグ' do
    #現在は022_song_tag_spec.rbにて個別対応
  end

  describe '楽曲の編集' do
    def f (song_name , artist_name , url = nil)
      wait_for_ajax
      find('#editsong').click; wait_for_ajax
      song_name and fill_in 'song' , with: song_name
      artist_name and fill_in 'artist' , with: artist_name
      url and fill_in 'url' , with: url
      click_on '登録'; wait_for_ajax
    end
    before do
      login 'sa2knight'
    end
    it '正常' do
      visit '/song/366'
      iscontain '妄想税 / DECO*27'
      f '住民税' , 'DECO*69'
      islack '妄想税 / DECO*27'
      iscontain '住民税 / DECO*69'
    end
    it '曲名なし' do
      visit '/song/365'
      f '' , 'HOGEHOGE'
      iscontain 'ニビョウカン / MARUDARUMA'
      islack 'HOGEHOGE'
    end
    it '歌手名なし' do
      visit '/song/364'
      f 'FUGAFUGA' , ''
      iscontain 'すろぉもぉしょん / ピノキオP'
      islack 'FUGAFUGA'
    end
    it 'URL無効' do
      visit '/song/360'
      f 'HAGEHAGE' , 'TIBITIBI' , '52,ないと,,袖触れ合うも他生の縁,磯P,0,,,'
      iscontain 'パンチラ・オブ・ジョイトイ / グループ魂'
      islack ['HAGEHAGE' , 'TIBITIBI']
    end
    it 'キャンセル' do
      visit '/song/363'
      find('#editsong').click; wait_for_ajax
      fill_in 'song' , with: '新しいの'
      fill_in 'artist' , with: '新アーティスト'
      click_on 'キャンセル'
      iscontain 'Boys be Smile / 鈴湯'
      islack ['新しいの' , '新アーティスト']
    end
    it '未ログイン時' do
      logout()
      visit '/song/363'; wait_for_ajax
      cant_find('#editsong')
    end
  end

  describe '歌唱履歴に追加' do
    def f (mode = 0)
      find('#create_history_image').click; wait_for_ajax
      if mode == 1
        click_on '終了';
      end
      if mode == 2
        click_on '登録'; wait_for_ajax
        click_on '終了';
        visit '/'
        find('#recent_karaoke_link').click
      end
      wait_for_ajax
    end
    before do
      login 'sa2knight'
    end
    it '曲名/歌手名が自動入力される' do
      visit '/song/314'
      f()
      expect(find('#song').value()).to eq 'スカイクラッドの観測者'
      expect(find('#artist').value()).to eq 'いとうかなこ'
    end
    it '登録ダイアログを閉じてもリダイレクトしない' do
      visit '/song/68'; wait_for_ajax
      f(1)
      expect(current_path).to eq '/song/68'
    end
    it '前回のカラオケに登録される' do
      visit '/song/67'
      f(2)
      history = table_to_hash('karaoke_detail_history_1')
      expect(history[-1]['tostring']).to eq '52,ないと,,袖触れ合うも他生の縁,磯P,-3,,,'
    end
    it 'ログインしていないとアイコンが表示されない' do
      logout
      visit '/song/350'
      cant_find('#create_history_image')
    end
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

  describe '歌う曲に迷ったら' do
    it 'ログイン済み' do
      login 'sa2knight'
      visit '/song/'
      expect(!!current_path.match(%r|/song/[0-9]+|)).to eq true
    end
    it 'ログインなし' do
      logout
      visit '/song/'
      expect(!!current_path.match(%r|/song/[0-9]+|)).to eq true
    end
  end

end
