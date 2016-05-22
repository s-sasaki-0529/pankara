require_relative '../rbase'
include Rbase

# テスト用データベース構築
init = proc do
  `zenra init -d 2016_05_15_16_33`
end

url = '/karaoke/detail/8'

# テスト実行
describe 'Attendanceの編集' , :js => true do
  before(:all , &init)
  
  before do
    login 'unagipai'
    visit url
  end
  
  after :each do
    wait_for_ajax
  end

  it '参加情報の編集' do
    find('#tab_5').click

    #編集前の情報
    iscontain '1600'
    iscontain '久しぶり'
 
    #参加情報編集ダイアログ表示
    find('#memo_5').click
    iscontain '参加情報編集'
   
    #入力欄に編集前情報が表示されるか検証
    examine_value('price' , '1600')
    examine_value('memo' , '久しぶり！')

    #編集内容を入力して保存
    fill_in 'price' , with: '10000'
    fill_in 'memo' , with: '変更後の感想'
    find('#action_button').click
    
    find('#tab_5').click

    #編集後の情報
    iscontain '10000'
    iscontain '変更後の感想'
  end
end

