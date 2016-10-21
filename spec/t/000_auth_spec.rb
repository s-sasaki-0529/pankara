require_relative '../rbase'
include Rbase

# テスト用データベース構築
init = proc do
  `zenra init`
  User.create('march_user' , 'march_user' , 'マージユーザ')
end

# テスト実行
describe '認証系ページ' do
  before(:all,&init)
  it '画面表示' do
    visit '/'
    current_path_is "/auth/login"
  end
  it '不正ログインパターン' do
    login 'failed_user'
    current_path_is "/auth/login"
  end
  it '正常ログインパターン' do
    login 'march_user'
    current_path_is "/"
  end
  it 'ログアウト' do
    login 'march_user'
    current_path_is "/"
    visit '/auth/logout'
    current_path_is "/auth/login"
  end
  it 'ログイン成功時に直前のページにリダイレクト' do
    visit '/auth/logout'
    visit '/artist/'
    iscontain 'アーティスト一覧'
    link 'ログイン'
    current_path_is "/auth/login"
    fill_in 'username' , with: 'march_user'
    fill_in 'password' , with: 'march_user'
    find('#login_button').click
    iscontain 'アーティスト一覧'
  end
  it 'ログイン中にログイン画面アクセスでトップにリダイレクト' do
    login 'march_user'
    visit '/auth/login'
    expect(page.current_path).to eq '/'
  end
end
