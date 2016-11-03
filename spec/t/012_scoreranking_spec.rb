require_relative '../rbase'
include Rbase

# 定数定義
score_types = []
selecter = 'score_type_selecter'
nondata = '該当データなし'
url = '/ranking/score'

# テスト用データベース構築
init = proc do
  `zenra init -d 2016_02_21_15_54`
  score_types = ScoreType.List(true).collect {|st| "#{st['brand']} #{st['name']}"}
end

# テスト実行
describe '得点ランキング機能' do
  before(:all , &init)

  before do
    login 'sa2knight'
    visit url
  end

  it 'ランキングが正常に表示されるか' do
    # 該当データがある場合
    visit '1'
    table = table_to_hash('scoreranking_table')
    expect(table.length).to eq 20
    expect(table[0]['tostring']).to eq '1,夢に消えたジュリア サザンオールスターズ,ないと,夢に消えたジュリア,サザンオールスターズ,92.12'
    expect(table[19]['tostring']).to eq '20,もんだいガール きゃりーぱみゅぱみゅ,ともちん,もんだいガール,きゃりーぱみゅぱみゅ,88.15'
    # 該当データがない場合
    visit '5'
    expect(find('#nondata').text).to eq nondata
  end

  it 'あなたのランキングへの切り替え' do
    link 'あなたのランキングへ'
    table = table_to_hash('scoreranking_table')
    expect(table[19]['tostring']).to eq '20,嘘 シド,ないと,嘘,シド,87.87'
    link '全体のランキングへ'
  end

  it 'あなたのランキングへの切り替えリンク' do
    iscontain 'あなたのランキングへ'
    logout
    visit url
    islack 'あなたのランキングへ'
  end

  it 'リンクが正常に登録されているか' do
    visit '1'
    url = current_url
    examine_songlink '夢に消えたジュリア' , 'サザンオールスターズ' , url
    examine_artistlink 'サザンオールスターズ' , url
    examine_userlink 'ないと' , url
  end
end
