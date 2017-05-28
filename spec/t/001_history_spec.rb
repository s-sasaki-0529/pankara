require_relative '../rbase'
include Rbase

# テスト用データベース構築
init = proc do
  `zenra init -d 2017_05_24_04_00`
end

# 定数
url = 'http://localhost:8080/history/list/sa2knight'

# テスト実行
describe '歌唱履歴ページ' do

  before(:all,&init)
  before do
    visit url
  end

  # 満足度を☆表記で取得
  def satisfaction_stars(satisfaction_level = nil)
    satisfaction_level or return '-'
    stars = '★' * satisfaction_level
    stars += '☆' * (10 - satisfaction_level)
    return stars
  end

  # 歌唱履歴を評価
  def examine(row, num, date, song, artist, key, satisfaction = nil)
    selector = ".history-table:nth-child(#{row}) td"
    expect(page.all(selector)[0].text).to eq num
    expect(page.all(selector)[1].text).to eq date
    expect(page.all(selector)[3].text).to eq "#{song} / #{artist}"
    expect(page.all(selector)[4].text).to eq "キー: #{key}"
    expect(page.all(selector)[5].text).to eq satisfaction_stars(satisfaction)
  end

  # 歌唱履歴の満足度のみを評価
  def examine_satisfaction(row, satisfaction = nil)
    selector = ".history-table:nth-child(#{row}) td"
    expect(page.all(selector)[5].text).to eq satisfaction_stars(satisfaction)
  end

  it '歌唱履歴表示' do
    iscontain '1873 曲中 1 〜 24 曲目を表示中'
    examine(1, '1873', '2017-05-21', 'Stage of the ground', 'BUMP OF CHICKEN', 0, 8)
    examine(3, '1871', '2017-05-21', 'メルト', 'supercell', 0, 9)
  end

  describe 'ページング' do
    it '2ページ目' do
      visit '?page=2'
      examine(1, '1849', '2017-05-21', 'YUME日和', '島谷ひとみ', -4, 6)
      examine(3, '1847', '2017-05-21', '一騎当千', '梅とら', 3, 8)
      iscontain '1873 曲中 25 〜 48 曲目を表示中'
    end
    it '最終ページ' do
      visit '?page=79'
      examine(1, '1', '2016-01-03', 'オンリーロンリーグローリー', 'BUMP OF CHICKEN', 0)
      iscontain '1873 曲中 1873 〜 1873 曲目を表示中'
    end
  end

  describe '絞り込み' do
    it '曲名検索' do
      visit '?filter_category=song&filter_word=%E6%84%9B&pagenum=24' #愛
      examine(1, '1797', '2017-05-14', '恋愛裁判', '40mP', 5, 7)
      iscontain '11 曲中 1 〜 11 曲目を表示中'
    end
    it '歌手名検索' do
      visit '?filter_category=artist&filter_word=BUMP'
      examine(3, '1851', '2017-05-21', 'ひとりごと', 'BUMP OF CHICKEN', 0, 5)
      iscontain '186 曲中 1 〜 24 曲目を表示中'
    end
    it 'タグ名検索' do
      visit '?filter_category=tag&filter_word=VOCALOID'
      examine(2, '1870', '2017-05-21', 'Fire◎Flower', 'absorb', -1, 9)
      iscontain '904 曲中 1 〜 24 曲目を表示中'
    end
    it '表示件数変更' do
      visit '?pagenum=120'
      iscontain '1873 曲中 1 〜 120 曲目を表示中'
      visit '?pagenum=120&page=16'
      iscontain '1873 曲中 1801 〜 1873 曲目を表示中'
    end
    it '満足度(等しい)' do
      visit '?filter_satisfaction=9&filter_satisfaction_class=eq&pagenum=120'
      iscontain '51 曲中 1 〜 51 曲目を表示中'
      1.upto(51) {|i| examine_satisfaction(i, 9)}
    end
    it '満足度(以上)' do
      visit '?filter_satisfaction=9&filter_satisfaction_class=gt&pagenum=24'
      iscontain '56 曲中 1 〜 24 曲目を表示中'
      examine(1, '1871', '2017-05-21', 'メルト', 'supercell', 0, 9)
      examine(5, '1854', '2017-05-21', '君じゃなきゃダメみたい', 'オーイシマサヨシ', 0, 10)
    end
    it '満足度(未満)' do
      visit '?filter_satisfaction=3&filter_satisfaction_class=lt&pagenum=24'
      iscontain '3 曲中 1 〜 3 曲目を表示中'
      examine(1, '1600', '2017-03-05', 'アスノヨゾラ哨戒班', 'Orangestar', 4, 2)
      examine(2, '1560', '2017-02-26', 'サンドリヨン', 'Dios/シグナルP', 0, 2)
    end
    it '満足度と曲名混合' do
      visit '?filter_category=artist&filter_word=BUMP+OF+CHICKEN&filter_satisfaction=10&filter_satisfaction_class=eq'
      iscontain '1 曲中 1 〜 1 曲目を表示中'
      examine(1, '1703', '2017-04-02', 'バトルクライ', 'BUMP OF CHICKEN', 0, 10)
    end
    it '不要なフォームが表示されない' do
      islack '並び順'
      islack 'あなたと共通の持ち歌のみ'
    end
    it 'リセット' do
      click_on '表示'
      expect(current_url == url).to eq false
      click_on 'リセット'
      expect(current_url == url).to eq true
    end
  end

  it 'リンク' do
    examine_songlink('全力少年', 'スキマスイッチ', url)
    examine_artistlink('doriko', url)
    link '1867'
    examine_historylink('ないと', '珍しく昼間に', 'インビジブル')
  end

end
