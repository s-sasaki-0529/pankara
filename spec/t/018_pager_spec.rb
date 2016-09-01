require_relative '../rbase'
include Rbase

# テスト用データベース構築
init = proc do
  `zenra init -d 2016_05_18_04_00`
end

url = '/history/tomotin'

def examine_page(page)
  wait_for_ajax
  current_page = current_url[-1].to_i
  expect(current_page).to eq page
end

# テスト実行
describe 'ページャ機能全般' , :js => true do

  before(:all,&init)
  before { visit url }

  it '指定したページ' do
    1.upto(5).each do |i|
      all("#pager_page_#{i} > a")[0].click
      examine_page(i)
    end
  end

  it '先頭ページ' do
    all("#pager_page_3 > a")[0].click
    examine_page(3)
    all("#pager_first_page > a")[0].click
    examine_page(1)
  end

  it '末尾ページ' do
    all("#pager_last_page > a")[0].click
    examine_page(5)
  end

  it '次のページ' do
    1.upto(4) do |i|
      all("#pager_next_page > a")[0].click
      examine_page(i + 1)
    end
    islack('次')
  end

  it '前のページ' do
    all("#pager_page_3 > a")[0].click
    2.downto(1) do |i|
      all("#pager_prev_page > a")[0].click
      examine_page(i)
    end
    islack('前')
  end

end
