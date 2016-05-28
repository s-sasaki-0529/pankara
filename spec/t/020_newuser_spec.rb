require_relative '../rbase'
include Rbase

# テスト用データベース構築
init = proc do
  `zenra init -d 2016_05_28_19_02`
end

# テスト実行
describe '新規登録したユーザで各ページを閲覧' do
  before(:all , &init)
  before do
    login 'test'
  end
  it 'トップページ' do
    iscontain '記録がありません'
    iscontain '友達がいません(笑)'
  end
  it 'カラオケ一覧' do
    visit 'karaoke/user'
    iscontain 'カラオケの記録がありません'
  end
  it '歌唱履歴' do
    visit 'history'
    iscontain '歌唱履歴がありません'
  end
  it '楽曲詳細画面' do
    visit 'song/1'
    iscontain 'あなたの 採点履歴がありません'
    iscontain '歌唱履歴がありません'
  end
  it 'アーティスト詳細画面' do
    visit 'artist/1'
    iscontain 'BUMP OF CHICKEN'
  end
  it 'ユーザページ' do
    visit 'user'
    iscontain 'カラオケ記録がありません'
    iscontain '歌唱履歴がありません'
  end
  it '設定画面' do
    visit '/config'
    iscontain 'まだ認証を行っていません'
  end
end
