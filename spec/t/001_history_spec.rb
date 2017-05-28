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
    stars = ''
    satisfaction_level.times {|i| stars += '★'}
    (10 - satisfaction_level).times {|i| stars += '☆'}
    return stars
  end

  # 歌唱履歴を評価
  def examine(row, num, date, song, artist, key, satisfaction)
    selector = ".history-table:nth-child(#{row}) td"
    expect(page.all(selector)[0].text).to eq num
    expect(page.all(selector)[1].text).to eq date
    expect(page.all(selector)[3].text).to eq "#{song} / #{artist}"
    expect(page.all(selector)[4].text).to eq "キー: #{key}"
    expect(page.all(selector)[5].text).to eq satisfaction_stars(satisfaction)
  end

  it '表示' do
    examine(1, '1873', '2017-05-21', 'Stage of the ground', 'BUMP OF CHICKEN', 0, 8)
    examine(3, '1871', '2017-05-21', 'メルト', 'supercell', 0, 9)
  end

  it 'ページング' do
    visit '?page=2'
    examine(1, '1849', '2017-05-21', 'YUME日和', '島谷ひとみ', -4, 6)
    examine(3, '1847', '2017-05-21', '一騎当千', '梅とら', 3, 8)
  end

  it 'リンク' do
    examine_songlink('全力少年', 'スキマスイッチ', url)
    examine_artistlink('doriko', url)
    link '1867'
    examine_historylink('ないと', '珍しく昼間に', 'インビジブル')
  end

end
