require_relative '../rbase'
include Rbase

# テスト用データベース構築
init = proc do
  `zenra init`
  User.create('unagipai' , 'unagipai' , 'ちゃら')
end

# テスト実行
describe '履歴入力用ダイアログのテスト', :js => true do

  # 定数定義
  karaoke_contents = [
    'カラオケ新規作成',
    'カラオケ名',
    '日時',
    '時間',
    '店',
    '店舗',
    '機種',
  ]
  history_contents = [
    '曲名', 
    '歌手',
    'キー',
    '採点方法',
    '採点',
  ]
  history_data = {
    'song' => '  心絵   ',
    'artist' => ' ロードオブメジャー',
    'score_type' => 'JOYSOUND 全国採点',
    'score' => 80
  }

  # 汎用関数
  def input_karaoke
    page.find('#name')
    fill_in 'name', with: '入力ダイアログテスト用カラオケ'
    js('$("#datetime").val("2016-02-20 12:00")')
    select '02時間00分', from: 'plan'
    fill_in 'store', with: '歌広場'
    fill_in 'branch', with: '相模大野店'
    select 'JOYSOUND MAX', from: 'product'
  end

  def input_history_with_data(history, num = 0)
    page.find('#song')
    fill_in 'song', with: history['song']
    fill_in 'artist', with: history['artist']
    select history['score_type'], from: 'score_type'
    fill_in 'score', with: history['score']
    wait_for_ajax
  end

  def input_history(song_value = 0 , artist_value = song_value , score_value = artist_value)
    page.find('#song')
    score = 0 + score_value
    score = 100 if score > 100
    fill_in 'song', with: "song#{song_value}"
    fill_in 'artist', with: "artist#{artist_value}"
    select 'JOYSOUND 全国採点', from: 'score_type'
    fill_in 'score', with: score
    wait_for_ajax
  end

  # 登録ボタンを押して、結果画面に遷移したら戻るボタンを押す
  def click_buttons(*buttons)
    buttons.each do |b|
      click_on b; wait_for_ajax
    end
  end

  before(:all , &init)
  after :each do
    wait_for_ajax
  end
  before do
    login 'unagipai'
    js 'register.createKaraoke();'
  end

  describe '正常パターン' do
    it 'ダイアログが正常に表示されるか' do
      iscontain karaoke_contents
    end

    it 'ダイアログの画面が正常に遷移されるか' do
      input_karaoke
      js('register.submitKaraokeRegistrationRequest();');
      iscontain history_contents
    end

    it '入力内容が正しく登録されるか' do
      input_karaoke
      js('register.submitKaraokeRegistrationRequest();');
      input_history_with_data history_data, 1
      click_buttons('登録', '戻る', '終了')
      karaoke = [
        '2016-02-20',
        '2.0',
        '歌広場 相模大野店',
        'JOYSOUND(MAX)',
        'ちゃら'
      ]
      iscontain karaoke

      history = [
        'ちゃら',
        '心絵',
        'ロードオブメジャー',
        '0',
        '全国採点',
        '80.0'
      ]
      iscontain history
    end

    it '歌唱回数が正しく表示されるか' do
      input_karaoke
      js('register.submitKaraokeRegistrationRequest();');
      input_history 1234 , 4567
      click_buttons('登録'); wait_for_ajax
      iscontain '歌唱履歴の登録に成功しました'
      iscontain ['song1234', 'artist4567', '初歌唱']
      tmp_sang_count = find('.total-sang-count').text().to_i
      click_buttons('戻る')
      3.times do |i|
        input_history 1234 , 4567
        click_buttons('登録')
        iscontain '歌唱履歴の登録に成功しました'
        iscontain ['song1234', 'artist4567', "#{i + 2}回目", "#{tmp_sang_count + i + 1}曲目"]
        click_buttons('戻る')
      end
    end

    it '20件登録されるか' do
      input_karaoke
      js('register.submitKaraokeRegistrationRequest();');
      20.times do |i|
        input_history i
        click_buttons('登録', '戻る')
      end
      click_buttons('終了')
      histories = []
      20.times do |i|
        histories.push "song#{i}"
        histories.push "artist#{i}"
      end
      iscontain histories
    end
  end

  describe '異常パターン' do
    def is_karaoke_register
      iscontain ['カラオケ名' , '日時' , '時間' , '店' , '店舗' , '機種']
    end
    def is_history_register
      iscontain ['曲名' , '歌手' , 'キー' , '採点方法']
    end
    def histories_num
      return `zenra mysql -se "select count(history.id) from history"`
    end
    def is_null_score_last_history
      history = `zenra mysql -se "select score_type , score from history order by id desc limit 1"`.gsub(/\s/ , '')
      expect(history).to eq 'NULLNULL'
    end
    describe 'カラオケ登録' do
      it '未ログイン' do
        logout()
        js('register.createKaraoke();')
        js('register.submitKaraokeRegistrationRequest();');
        is_karaoke_register
      end
      it '日時バリデーションエラー' do
        login 'unagipai'
        js('register.createKaraoke();')
        js('$("#datetime").val("hogehoge")')
        js('register.submitKaraokeRegistrationRequest();');
        is_karaoke_register
      end
    end
    describe '歌唱履歴登録' do
      before do
        login 'unagipai'
        js('register.createKaraoke();')
        js('register.submitKaraokeRegistrationRequest();');
        is_history_register
      end
      it '曲名なし' do
        old_num = histories_num
        fill_in 'artist' , with: 'hogehoge'
        click_buttons('登録'); wait_for_ajax
        new_num = histories_num
        expect(old_num).to eq new_num
      end
      it '歌手名なし' do
        old_num = histories_num
        fill_in 'song' , with: 'fugafuga'
        click_buttons('登録'); wait_for_ajax
        new_num = histories_num
        expect(old_num).to eq new_num
      end
      it '得点0' do
        fill_in 'song' , with: 'hoge'
        fill_in 'artist' , with: 'fuga'
        select 'JOYSOUND 全国採点', from: 'score_type'
        fill_in 'score' , with: '0'
        click_buttons('登録'); wait_for_ajax
        is_null_score_last_history
      end
      it '採点方法なし' do
        fill_in 'song' , with: 'hoge'
        fill_in 'artist' , with: 'fuga'
        select '', from: 'score_type'
        js("$('#score').val('100')");
        click_buttons('登録'); wait_for_ajax
        is_null_score_last_history
      end
    end
  end

  describe 'ダイアログウィジェット' do
    describe 'キースライダ' do
      before do
        input_karaoke
        js('register.submitKaraokeRegistrationRequest();');
      end
      it 'プラスボタン' do
        expect(find('#slidervalue').text()).to eq '0'
        js("$('.slider-btn').last().click()")
        expect(find('#slidervalue').text()).to eq '1'
      end
      it 'マイナスボタン' do
        expect(find('#slidervalue').text()).to eq '0'
        js("$('.slider-btn').first().click()")
        expect(find('#slidervalue').text()).to eq '-1'
      end
    end
    describe '採点モード' do
      before do
        input_karaoke
      end
      it 'JOYSOUNDの場合' do
        select 'JOYSOUND MAX', from: 'product'
        js('register.submitKaraokeRegistrationRequest();');
        expect(ejs("$('#score_type option').text();")).to eq 'JOYSOUND 全国採点JOYSOUND 分析採点JOYSOUND その他その他 その他'
      end
      it 'DAMの場合' do
        select 'DAM LIVE DAM', from: 'product'
        js('register.submitKaraokeRegistrationRequest();');
        expect(ejs("$('#score_type option').text();")).to eq 'DAM ランキングバトルDAM 精密採点DAM その他その他 その他'
      end
      it 'その他の場合' do
        select 'その他 その他', from: 'product'
        js('register.submitKaraokeRegistrationRequest();');
        expect(ejs("$('#score_type option').text();")).to eq 'JOYSOUND 全国採点JOYSOUND 分析採点JOYSOUND その他DAM ランキングバトルDAM 精密採点DAM その他その他 その他'
      end
    end
    describe '得点入力欄' do
      before do
        input_karaoke
        js('register.submitKaraokeRegistrationRequest();');
        select 'JOYSOUND 全国採点', from: 'score_type'
      end
      it '採点モード指定なしの場合得点欄を表示しない' do
        select '', from: 'score_type'
        expect(ejs("$('#score_area').css('display')")).to eq 'none'
      end
      it '採点モード指定ありの場合得点欄を表示する' do
        expect(ejs("$('#score_area').css('display')")).to eq 'block'
      end
      it '101点以上入力で100点に修正' do
        fill_in 'score', with: 120
        js("$('#score').blur()")
        expect(find('#score').value()).to eq '100'
      end
      it '-n点入力でn点に修正' do
        fill_in 'score', with: -50
        js("$('#score').blur()")
        expect(find('#score').value()).to eq '50'
      end
      it '小数点が複数ある場合に補正' do
        fill_in 'score', with: '85.92.38.59'
        js("$('#score').blur()")
        expect(find('#score').value()).to eq '85.92'
      end
      it 'アルファベットが含まれている場合に訂正' do
        fill_in 'score', with: '8fadlsfl2.jfaa38'
        js("$('#score').blur()")
        expect(find('#score').value()).to eq '82.38'
      end
    end
  end
end
