require_relative '../rbase'
include Rbase

# テスト用データベース構築
init = proc do
  `zenra init -d 2016_02_28_21_57`
end

# テスト実行
describe 'Karaoke/Historyの編集/削除' , :js => true do
  before(:all , &init)
  
  before do
    login 'sa2knight'
    visit '/karaoke/user/sa2knight'
  end
  
  after :each do
    wait_for_ajax
  end

  it '既存カラオケの編集' do
    # 変更前のkaraokeを検証
    page.all('tr')[3].click
    iscontain('2016年 2/24回目')
    old_table = table_to_hash('karaoke_detail_description')
    expect(old_table[0]['tostring']).to eq '2016-01-17 14:50:00,3.0,歌広場 亀戸店,JOYSOUND(CROSSO),ないと ともちん,' 

    # 変更作業
    find('#karaoke_detail_description').all('td')[5].find('img').click
    wait_for_ajax
    iscontain('カラオケの新規作成') #Todo 新規作成って出るのはおかしいやろ
    fill_in 'name' , with: '変更後のカラオケ名'
    fill_in 'datetime' , with: '2016/03/25 20:30'
    fill_in 'store' , with: 'シダックス'
    fill_in 'branch' , with: '盛岡店'
    select '12時間00分' , from: '時間'
    select 'JOYSOUND WAVE' , from: '機種'
    click_on '保存'
    wait_for_ajax
    
    # 変更後のkaraokeを検証
    new_table = table_to_hash('karaoke_detail_description')
    expect(new_table[0]['tostring']).to eq '2016-03-25 20:30:00,12.0,シダックス 盛岡店,JOYSOUND(WAVE),ないと ともちん,'
  end
end
