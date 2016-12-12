require_relative '../rbase'
include Rbase

# テスト用データベース構築
init = proc do
  `zenra init -d 2016_12_09_00_20`
end

# 定数定義
url = '/'

# テスト実行
describe 'タイムライン' do
  before(:all , &init)
  it 'タイムラインが正しく表示されるか' do
    login 'sa2knight'
    visit url
    timelines = class_to_elements('div-timeline')
    tl_text = id_to_element('div_timelines').text
    expect(timelines.length).to eq 10
    expect(tl_text.index('ともちん').nil?).to eq false
    expect(tl_text.index('へたれ').nil?).to eq true
    expect(tl_text.index('ちゃら').nil?).to eq false
    expect(tl_text.index('ウォーリー').nil?).to eq true
    expect(tl_text.index('さっちー').nil?).to eq false
  end
  it 'リンクが正常に登録されているか' do
    login 'sa2knight'
    visit url
    examine_userlink 'さっちー' , url
    examine_karaokelink 'ヒトカラ' , url
  end
end
