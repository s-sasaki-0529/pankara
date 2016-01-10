require_relative 'rbase'
include Rbase

user = 'user1'
url = '/karaoke'
	
describe 'カラオケ一覧画面' do
	it '一覧表示' do
		login user
		visit url
		iscontain 'カラオケ記録一覧'
		iscontain ['カラオケ5' , '3.0' , 'カラオケ店1 店舗2' , 'DAM(LIVE DAM)'  , 'クソだった']
	end
end
