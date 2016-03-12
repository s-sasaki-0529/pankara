require_relative '../rbase'
include Rbase

# テスト用データベース構築
init = proc do
  `zenra init -d 2016_02_14_17_39`
end

# 定数定義

# テスト実行
describe 'バスタオル' , :js => true do
  before(:all , &init)
  before do 
    login 'sa2knight'
    wait_for_ajax
    system 'sleep 1'
  end
  after :each do
  end
  it 'JavaScriptが実行されているか' do
    expect(page.first('.simply-scroll-container').nil?).to eq false
  end
  it 'サムネイルが並んでいるか' do
    images = page.first('.simply-scroll-list').all('li')
    expect(images.length).to eq 20 + 11
  end
  it 'オンマウスで楽曲情報が表示されるか' do
    execute_script '$("#slider > li:first > img").trigger("mouseenter")'
    expect(page.find('#bathtowel_info').text).to eq 'カノン (宮野真守)'
  end
  it 'サムネイルクリック時にプレイヤーが表示されるか' do
    execute_script '$("#slider > li:first > img").trigger("click")'
    wait_for_ajax
    expect(page.find('#ui-id-1').text).to eq 'カノン (宮野真守)'
    iframes = youtube_links()
    expect(iframes.length).to eq 1
    expect(iframes[0]).to eq 'https://www.youtube.com/embed/a6zJ9tWZgbM'
    execute_script '$(".ui-dialog-title").trigger("click")'
    expect(find('h2').text).to eq 'カノン / 宮野真守'
  end
end
