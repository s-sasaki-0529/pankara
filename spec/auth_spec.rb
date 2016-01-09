require_relative 'rbase'
include Rbase

describe 'ログイン機能' do
	message = 'ログインしてください'
	it '画面表示' do
		visit '/'
		iscontain message
	end
	it '不正ログインパターン' do
		login 'faildname'
		iscontain message
	end
	it '正常ログインパターン' do
		login 'user1'
		islack message
	end
	it 'ログアウト' do
		visit '/logout'
		iscontain message
	end
end
