require_relative '../rbase'
include Rbase

# テスト用データベース構築
init = proc do
  `zenra init -d 2016_02_28_21_57`
end

url = '/karaoke/user/sa2knight'

# テスト実行
describe 'Karaokeの編集/削除' , :js => true do
  before(:all , &init)
  
  before do
    login 'sa2knight'
    visit url
  end
  
  after :each do
    wait_for_ajax
  end

  it '既存カラオケの編集と削除' do
    # 変更前のkaraokeを検証
    page.all('tr')[1].click
    iscontain('2016年 4/24回目')
    old_table = table_to_hash('karaoke_detail_description')
    expect(old_table[0]['tostring']).to eq '2016-02-13,5.0,カラオケ館 亀戸店,JOYSOUND(f1),55,,'

    # 変更作業
    find('#editkaraoke').click
    wait_for_ajax
    iscontain('カラオケ編集')
    fill_in 'name' , with: '変更後のカラオケ名'
    fill_in 'datetime' , with: '2020/03/25 20:30'
    fill_in 'store' , with: 'シダックス'
    fill_in 'branch' , with: '盛岡店'
    select '12時間00分' , from: '時間'
    select 'JOYSOUND WAVE' , from: '機種'
    click_on '保存'
    wait_for_ajax
    
    # 変更後のkaraokeを検証
    new_table = table_to_hash('karaoke_detail_description')
    expect(new_table[0]['tostring']).to eq '2020-03-25,12.0,シダックス 盛岡店,JOYSOUND(WAVE),55,,'
  
    # 現在のkaraokeの件数を確認
    visit url
    old_karaoke_num = DB.new(:FROM => 'karaoke').execute_all.count
    old_rows_num = page.all('tr').count
    old_target_row = table_to_hash('karaokelist_table')[0]['tostring']
    expect(old_karaoke_num).to eq 7
    expect(old_rows_num).to eq 5
    expect(old_target_row).to eq '2020-03-25 20:30:00,変更後のカラオケ名,12.0,シダックス 盛岡店,JOYSOUND(WAVE),'

    # karaokeを削除する
    page.all('tr')[1].click
    iscontain('変更後のカラオケ名')
    find('#editkaraoke').click
    wait_for_ajax
    click_on '削除'
    wait_for_ajax

    # 削除後のkaraokeの件数を確認
    visit url
    new_karaoke_num = DB.new(:FROM => 'karaoke').execute_all.count
    new_rows_num = page.all('tr').count
    new_target_row = table_to_hash('karaokelist_table')[0]['tostring']
    expect(old_karaoke_num - new_karaoke_num).to eq 1
    expect(old_rows_num - new_rows_num).to eq 1
    expect(old_target_row != new_target_row).to eq true
  end
end
