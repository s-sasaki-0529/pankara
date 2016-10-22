require_relative '../rbase'
include Rbase

# テスト用データベース構築
init = proc do
  `zenra init -d 2016_08_24_04_00`
end

# テスト実行
describe '曲名・歌手名のガイドライン' , :js => true do
  before(:all , &init)
  before do
    login 'sa2knight'
  end

  it '画面の切り替え' do
    js('register.createSong();')
    iscontain ['曲名' , '歌手']
    islack ['曲名の入力指針' , '歌手名の入力指針']
    click_on 'ガイドライン';
    islack ['曲名' , '歌手']
    iscontain ['曲名の入力指針' , '歌手名の入力指針']
    click_on '戻る';
    iscontain ['曲名' , '歌手']
    islack ['曲名の入力指針' , '歌手名の入力指針']
  end
 
  it 'タップで例をホップアップ' do
    js('register.createSong();')
    click_on 'ガイドライン'
    islack 'メリッサ'
    click_on 'カラオケ特有の表記は不要'
    iscontain 'メリッサ'
    click_on 'カバーは原曲に統一'
    islack 'メリッサ'
    iscontain '中島みゆき'
  end
  
  it '画面遷移時に入力内容を保持' do
    js('register.createSong();')
    fill_in 'artist' , with: 'BUMP OF CHICKEN'
    fill_in 'song' , with: '天体観測'
    click_on 'ガイドライン'
    click_on '戻る'
    expect(find('#song').value()).to eq '天体観測'
    expect(find('#artist').value()).to eq 'BUMP OF CHICKEN'
  end
  
  it '画面遷移時にもしかしてを非表示にする' do
    js('register.createSong();')
    fill_in 'artist' , with: 'ポルノグラフィティ'; wait_for_ajax
    fill_in 'song' , with: ''; wait_for_ajax
    iscontain 'アゲハチョウ'
    click_on 'ガイドライン'
    islack 'アゲハチョウ'
  end
  
  it '画面遷移時にホップアップを非表示に' do
    js('register.createSong();')
    click_on 'ガイドライン'
    click_on 'カラオケ特有の表記は不要'
    iscontain 'メリッサ'
    click_on '戻る'
    click_on 'ガイドライン'
    islack 'メリッサ'
  end

end

