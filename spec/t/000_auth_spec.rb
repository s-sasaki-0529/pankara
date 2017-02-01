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
  mes1 = 'IDまたはパスワードが正しいかチェックしてください'
  mes2 = 'ログアウトが完了しました'

  it '画面表示' do
    visit '/'
    current_path_is "/auth/login"
    islack [mes1 , mes2]
  end
  it '不正ログインパターン' do
    login 'failed_user' , 'failed_pw'
    current_path_is "/auth/login"
    iscontain mes1
    islack mes2
  end
  it '正常ログインパターン' do
    login 'march_user' , 'march_user'
    current_path_is "/"
  end
  it 'ログアウト' do
    login 'march_user' , 'march_user'
    current_path_is "/"
    visit '/auth/logout'
    current_path_is "/auth/login"
    iscontain mes2
    islack mes1
  end
  it 'ログイン成功時に直前のページにリダイレクト' do
    visit '/auth/logout'
    visit '/karaoke/list'
    link 'ログイン'
    current_path_is "/auth/login"
    fill_in 'username' , with: 'march_user'
    fill_in 'password' , with: 'march_user'
    find('#login_button').click
    expect(current_path).to eq '/karaoke/list'
  end
  it 'ログイン中にログイン画面アクセスでトップにリダイレクト' do
    login 'march_user' , 'march_user'
    visit '/auth/login'
    expect(page.current_path).to eq '/'
  end
end
