require_relative '../rbase'
include Rbase

# テスト用データベース構築
init = proc do
  `zenra init`
  User.create('march_user' , 'march_user' , 'マージユーザ')
end

# 定数定義
message = 'ログインしてください'

# テスト実行
describe '認証系ページ' do
  before(:all,&init)
  it '画面表示' do
    visit '/'
    iscontain message
  end
  it '不正ログインパターン' do
    login 'failed_user'
    iscontain message
  end
  it '正常ログインパターン' do
    login 'march_user'
    islack message
  end
  it 'ログアウト' do
    login 'march_user'
    islack message
    visit '/logout'
    iscontain message
  end
  it 'ログイン成功時に直前のページにリダイレクト' do
    visit '/logout'
    visit '/artist_list'
    iscontain 'アーティスト一覧'
    link 'ログイン'
    iscontain message
    fill_in 'username' , with: 'march_user'
    fill_in 'password' , with: 'march_user'
    find('#login_button').click
    iscontain 'アーティスト一覧'
  end
  it 'ログイン中にログイン画面アクセスでトップにリダイレクト' do
    login 'march_user'
    visit '/login'
    expect(page.current_path).to eq '/'
  end
end
