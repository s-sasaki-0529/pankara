require_relative '../rbase'
include Rbase

url = '/karaoke/detail/7'

def headline
  table_to_hash('karaoke_detail_history_all')[0]['tostring']
end

# テスト実行
describe 'Historyの編集/削除' , :js => true do
  
  before do
    `zenra init -d 2016_02_28_21_57`
    login 'sa2knight'
    visit url
    find('#karaoke_detail_history_all').all('th')[6].click
    wait_for_ajax
    expect(headline).to eq 'ないと,,MISTAKE,ナナホシ管弦楽団,-3,全国採点,77.08,'
    wait_for_ajax 
  end
  
  after :each do
    wait_for_ajax
  end

  it '編集' do
    find('#karaoke_detail_history_all').all('td')[7].find('img').click
    fill_in 'song' , with: '変更後の曲名'
    fill_in 'artist' , with: '変更後の歌手名'
    select 'DAM その他' , from: '採点方法'
    fill_in '採点' , with: '100'
    click_on '保存'
    #Todo スライダ操作によるキー設定
    wait_for_ajax
    visit url
    iscontain('変更後の曲名')
    find('#karaoke_detail_history_all').all('th')[6].click
    find('#karaoke_detail_history_all').all('th')[6].click
    expect(headline).to eq 'ないと,,変更後の曲名,変更後の歌手名,-3,その他,100.00,'
  end

  it '削除' do
    old_num = table_to_hash('karaoke_detail_history_all').length
    expect(old_num).to eq 55
    find('#karaoke_detail_history_all').all('th')[6].click
    find('#karaoke_detail_history_all').all('td')[7].find('img').click
    wait_for_ajax
    click_on '削除'
    wait_for_ajax
    visit url
    find('#karaoke_detail_history_all').all('th')[6].click
    new_num = table_to_hash('karaoke_detail_history_all').length
    expect(new_num).to eq old_num - 1
  end
end
