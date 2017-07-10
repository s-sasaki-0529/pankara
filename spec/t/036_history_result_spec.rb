require_relative '../rbase'
include Rbase

# カラオケを作成
def createKaraoke(option_params = {})
  params = {
    name:      'テスト用カラオケ',
    datetime:  '2017-07-10 10:00',
    plan:      '02時間00分',
    store:     'カラオケ館',
    branch:    '亀戸店',
    product:   'JOYSOUND MAX',
  }.merge(option_params)
  js 'register.createKaraoke()'
  fill_in 'name', with: params[:name]
  js("$('#datetime').val('#{params[:datetime]}')")
  select params[:plan], from: 'plan'
  fill_in 'store', with: params[:store]
  fill_in 'branch', with: params[:branch]
  select params[:product], from: 'product'
  js('register.submitKaraokeRegistrationRequest();');
end

# 歌唱履歴を登録
def createHistory(option_params = {})
  params = {
    song:       'サンプル曲名',
    artist:     'サンプル歌手名',
    satisfaction_level: '★★★★★☆☆☆☆☆',
    score_type: 'JOYSOUND 分析採点',
    score:      '88.72',
  }.merge(option_params)
  fill_in 'song',   with: params[:song]
  fill_in 'artist', with: params[:artist]
  select params[:satisfaction_level], from: 'satisfaction_level'
  select params[:score_type], from: 'score_type'
  params[:score_type].empty? or fill_in 'score', with: params[:score]
  click_buttons('登録')
end

# ボタンをクリックする
def click_buttons(*buttons)
  buttons.each do |b|
    click_on b; wait_for_ajax
  end
end

# テスト用データベース構築
init = proc do
  `zenra init -d 2017_07_04_23_18`
end

# テスト実行
describe '歌唱履歴登録結果', :js => true do

  # テスト実行時にデータベースを初期化
  before(:all , &init)

  # テストグループごとに、wait_for_ajaxを実行
  after :each do
    wait_for_ajax
  end

  # テストグループごとに、最初にログインする
  before do
    login 'sa2knight'
  end

  describe '曲名/歌手名' do
    before do
      visit '/'
      createKaraoke
    end
    it '既存曲登録時に曲名/歌手名が表示される' do
      createHistory(song: '天体観測', artist: 'BUMP OF CHICKEN')
      examine_text_by_class('song-name', '天体観測')
      examine_text_by_class('artist-name', 'BUMP OF CHICKEN')
    end
    it '新規曲登録時に曲名/歌手名が表示される' do
      createHistory(song: 'どっこい音頭', artist: '坂上田村麻呂')
      examine_text_by_class('song-name', 'どっこい音頭')
      examine_text_by_class('artist-name', '坂上田村麻呂')
    end
  end

  describe '歌唱回数' do
    it '初回歌唱時は初歌唱と表示される' do
      createKaraoke
      createHistory(song: '山の上のエビフライ', artist: '中之条悟')
      examine_text_by_class('sang-count', '初歌唱')
    end
    it '2回目以降は歌唱回数が表示される' do
      createKaraoke
      createHistory(song: '天体観測', artist: 'BUMP OF CHICKEN')
      old_sang_count = find('.sang-count').text.to_i
      click_buttons('戻る')
      3.times do |i|
        createHistory(song: '天体観測', artist: 'BUMP OF CHICKEN')
        examine_text_by_class('sang-count', "#{old_sang_count + i + 1}回目")
        click_buttons('戻る')
      end
    end
  end

  describe '総歌唱回数' do
    it '総歌唱回数が正しく表示される' do
      createKaraoke
      createHistory
      old_total_sang_count = find('.total-sang-count').text.to_i
      click_buttons('戻る')
      3.times do |i|
        createHistory
        examine_text_by_class('total-sang-count', "#{old_total_sang_count + i + 1}曲目")
        click_buttons('戻る')
      end
    end
  end

  describe '備考欄' do
    it '初回は初歌唱と表示される' do
      createKaraoke
      createHistory(song: 'どっこい音頭ネオ', artist: '地球防衛軍')
      examine_text_by_class('since-info', '初歌唱')
    end
    it '日を跨いで2回目以降は何日ぶりか正しく表示される' do
      createKaraoke(datetime: '2017-07-07 10:00')
      createHistory(song: 'ランプ', artist: 'BUMP OF CHICKEN')
      examine_text_by_class('since-info', '32日(5カラオケ)ぶり')
      click_buttons('戻る')
      createHistory(song: 'PONPONPON', artist: 'きゃりーぱみゅぱみゅ')
      examine_text_by_class('since-info', '550日(59カラオケ)ぶり')
    end
    it '同日に複数回歌唱した場合は本日N回目と表示される' do
      createKaraoke
      createHistory(song: '少年の歌', artist: 'The Giant Banana')
      click_buttons('戻る')
      createHistory(song: '少年の歌', artist: 'The Giant Banana')
      examine_text_by_class('since-info', '本日2回目')
      click_buttons('戻る')
      createHistory(song: '少年の歌', artist: 'The Giant Banana')
      examine_text_by_class('since-info', '本日3回目')
    end
    it '複数カラオケ連続で同じ楽曲を登録した場合、Nカラオケ連続と表示される' do
      createKaraoke(datetime: '2017-12-31 10:00')
      createHistory(song: 'どっきゅん恋の戦争', artist: 'ともとも')
      examine_text_by_class('since-info', '初歌唱')
      visit '/'
      createKaraoke(datetime: '2018-01-01 10:00')
      createHistory(song: 'じゃがじゃがじゃん', artist: 'ぽんきっき')
      examine_text_by_class('since-info', '初歌唱')
      visit '/'
      createKaraoke(datetime: '2018-01-03 10:00')
      createHistory(song: 'じゃがじゃがじゃん', artist: 'ぽんきっき')
      examine_text_by_class('since-info', '2カラオケ連続2日ぶり')
      click_buttons('戻る')
      createHistory(song: 'どっきゅん恋の戦争', artist: 'ともとも')
      examine_text_by_class('since-info', '3日(2カラオケ)ぶり')
      visit '/'
      createKaraoke(datetime: '2018-01-10 10:00')
      createHistory(song: 'じゃがじゃがじゃん', artist: 'ぽんきっき')
      examine_text_by_class('since-info', '3カラオケ連続7日ぶり')
      click_buttons('戻る')
      createHistory(song: 'どっきゅん恋の戦争', artist: 'ともとも')
      examine_text_by_class('since-info', '2カラオケ連続7日ぶり')
    end
  end

  describe '採点情報' do
    before { createKaraoke }
    it '採点なしで登録した場合採点情報欄は表示されない' do
      createHistory(score_type: '')
      expect(class_to_elements('score-info').empty?).to eq true
    end
    it '採点ありで登録した場合採点情報欄が表示される' do
      createHistory
      expect(class_to_elements('score-info').empty?).to eq false
    end
    it '過去最高得点が存在する場合、その点数が表示される' do
      createHistory(song: '天体観測', artist: 'BUMP OF CHICKEN')
      examine_text_by_class('max-score', '90.15点(分析採点)')
    end
    it '過去最高得点が存在しない場合、初採点と表示される' do
      createHistory(song: '天体観測', artist: 'BUMP OF CHICKEN', score_type: 'JOYSOUND 全国採点')
      examine_text_by_class('max-score', '初採点(全国採点)')
    end
    it '採点結果列に得点が表示される' do
      createHistory(song: 'ray', artist: 'BUMP OF CHICKEN', score_type: 'JOYSOUND 全国採点', score: 77.94823)
      examine_text_by_class('score', '77.95点(全国採点)')
      click_buttons('戻る')
      createHistory(song: 'ray', artist: 'BUMP OF CHICKEN', score_type: 'JOYSOUND 分析採点', score: 98)
      examine_text_by_class('score', '98点(分析採点)')
    end
  end
end
