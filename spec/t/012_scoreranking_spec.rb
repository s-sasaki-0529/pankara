require_relative '../rbase'
include Rbase

# テスト用データベース構築
init = proc do
  `zenra init -d 2016_02_21_15_54`
end

# 定数定義
score_types = ScoreType.List(true).collect {|st| "#{st['brand']} #{st['name']}"}
selecter = 'score_type_selecter'
nondata = '該当データなし'

# テスト実行
describe '得点ランキング機能' do
  before(:all , &init)

  before do
    login 'sa2knight'
    visit '/ranking/score/'
  end

  it '採点モードの切り替えが正常に行われるか' , :js => true do
    score_types.each do |st|
      select st , from: selecter
      iscontain("得点ランキング #{st} 編")
    end
  end
  
  it 'ランキングが正常に表示されるか' do
    # 該当データがある場合
    visit '1'
    table = table_to_hash('scoreranking_table')
    expect(table.length).to eq 20
    expect(table[0]['tostring']).to eq '1,,ないと,夢に消えたジュリア,サザンオールスターズ,92.1'
    expect(table[19]['tostring']).to eq '20,,ともちん,もんだいガール,きゃりーぱみゅぱみゅ,88.2'
    expect(thumbnail_list.length).to eq 20
    # 該当データがない場合
    visit '5'
    expect(find('#nondata').text).to eq nondata
  end

  it 'リンクが正常に登録されているか' do
    visit '1'
    url = current_url
    examine_songlink '夢に消えたジュリア' , 'サザンオールスターズ' , url
    examine_artistlink 'サザンオールスターズ' , url
    examine_userlink 'ないと' , url
  end
end
