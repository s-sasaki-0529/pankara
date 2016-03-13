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
  it 'カラオケ概要が正常に表示されるか' do
    login 'sa2knight'
    visit url
    iscontain '祝本番環境リリースカラオケ'
    des_table = table_to_hash('karaoke_detail_description')
    expect(des_table[0]['tostring']).to eq '2016-03-05 11:00:00,7.0,カラオケの鉄人 銀座店,その他(その他),ないと へたれ ちゃら,'
  end
  it '歌唱履歴が正常に表示されるか' do
    login 'sa2knight'
    visit url
    history_table = table_to_hash('karaoke_detail_history')
    expect(history_table.length).to eq 75
    expect(history_table[0]['tostring']).to eq 'ないと,,Hello, world!,BUMP OF CHICKEN,0,,,'
    expect(history_table[3]['tostring']).to eq 'ちゃら,,はなまるぴっぴはよいこだけ,A応P,0,,,'
  end
  it 'リンクが正常に登録されているか' do
    login 'sa2knight'
    visit url
    examine_userlink('ないと' , url)
    examine_userlink('へたれ' , url)
    examine_userlink('ちゃら' , url)
    examine_songlink('Dragon Night' , 'SEKAI NO OWARI' , url)
    examine_artistlink('サイキックラバー' , url)
  end
end
