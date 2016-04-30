require_relative '../rbase'
include Rbase

url = '/karaoke/detail/8'

init = proc do
  `zenra init -d 2016_04_29_04_00`
end

def table_string(row)
  table_to_hash('karaoke_detail_history_all')[row]['tostring']
end

# テスト実行
describe 'Historyの編集/削除' , :js => true do
  
  before(:all,&init)
  before do
    login 'sa2knight'
    visit url
  end

  after :each do
    wait_for_ajax
  end

  it '編集と削除' do
    #編集
    iscontain('祝本番環境リリース')
    expect(table_string(8)).to eq 'ないと,,1/3の純情な感情,SIAM SHADE,0,その他,82.00,'
    find('#karaoke_detail_history_all').all('tr')[9].all('td')[7].find('img').click
    wait_for_ajax
    fill_in 'song' , with: '変更後の曲名'
    fill_in 'artist' , with: '変更後の歌手名'
    select 'DAM その他' , from: '採点方法'
    fill_in '採点' , with: '100'
    wait_for_ajax
    click_on '保存'
    wait_for_ajax
    visit url
    iscontain('変更後の曲名')
    islack('1/3の純情な感情')
    expect(table_string(8)).to eq 'ないと,,変更後の曲名,変更後の歌手名,0,その他,100.00,'

    #削除
    expect(table_to_hash('karaoke_detail_history_all').length).to eq 75
    expect(table_string(10)).to eq 'ちゃら,,DAN DAN心魅かれてく,FIELD OF VIEW,0,その他,73.00,'
    find('#karaoke_detail_history_all').all('tr')[11].all('td')[7].find('img').click
    wait_for_ajax
    click_on '削除'
    wait_for_ajax
    visit url
    expect(table_to_hash('karaoke_detail_history_all').length).to eq 74
    islack('DAN DAN心惹かれてく')
  end
end
