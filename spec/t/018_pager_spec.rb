require_relative '../rbase'
include Rbase

# テスト用データベース構築
init = proc do
  `zenra init -d 2016_05_18_04_00`
end

url = '/history/tomotin'

def examine_page(page)
  current_page = current_url[-1].to_i
  expect(current_page).to eq page
end

# テスト実行
describe 'ページャ機能全般' do

  before(:all,&init)
  before { visit url }

  it '指定したページ' do
    1.upto(5).each do |i|
      find("#pager_page_#{i} > a").click
      examine_page(i)
    end
  end

  it '先頭ページ' do
    visit '?page=5'
    examine_page(5)
    find("#pager_first_page > a").click
    examine_page(1)
  end

  it '末尾ページ' do
    find("#pager_last_page > a").click
    examine_page(5)
  end

  it '次のページ' do
    1.upto(4) do |i|
      find("#pager_next_page > a").click
      examine_page(i + 1)
    end
    islack('次のページ')
  end

  it '前のページ' do
    visit '?page=5'
    4.downto(1) do |i|
      find("#pager_prev_page > a").click
      examine_page(i)
    end
    islack('前のページ')
  end

end
