require_relative '../rbase'
include Rbase

# テスト用データベース構築
init = proc do
  `zenra init -d 2016_03_13_22_01`
  `zenra mysql -e "update song set url = '' where id = 7"`
end

# 定数定義
url = '/karaoke/detail/8'

# テスト実行
describe 'カラオケ詳細ページ' do
  before(:all,&init)
  before do
    login 'sa2knight'
    visit url
  end
  it 'カラオケ概要が正常に表示されるか' do
    iscontain '祝本番環境リリースカラオケ'
    des_table = table_to_hash('karaoke_detail_description')
    expect(des_table[0]['tostring']).to eq '2016-03-05 11:00:00,7.0,カラオケの鉄人 銀座店,その他(その他),75,'
  end
  it 'カラオケの集計が正常に表示されるか' do
    col_table = table_to_hash('karaoke_member_table')
    expect(col_table.length).to eq 3
    expect(col_table[0]['tostring']).to eq 'ないと,1600,25,97.00,へたれとちゃらさんと３人で'
    expect(col_table[1]['tostring']).to eq 'へたれ,1600,23,97.00,緊張するんじゃあ'
    expect(col_table[2]['tostring']).to eq 'ちゃら,1600,27,94.00,久しぶり！'
  end
  it '歌唱履歴が正常に表示されるか' do
    history_table = table_to_hash('karaoke_detail_history')
    expect(history_table.length).to eq 75
    expect(history_table[0]['tostring']).to eq 'ないと,,Hello, world!,BUMP OF CHICKEN,0,,,'
    expect(history_table[3]['tostring']).to eq 'ちゃら,,はなまるぴっぴはよいこだけ,A応P,0,,,'
  end
  it 'リンクが正常に登録されているか' do
    examine_userlink('ないと' , url)
    examine_userlink('へたれ' , url)
    examine_userlink('ちゃら' , url)
    examine_songlink('Dragon Night' , 'SEKAI NO OWARI' , url)
    examine_artistlink('サイキックラバー' , url)
  end
end
