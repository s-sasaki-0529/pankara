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
describe 'ログイン機能' do
	before(&init)
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
		visit '/logout'
		iscontain message
	end
end