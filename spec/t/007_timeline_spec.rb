require_relative '../rbase'
include Rbase

# テスト用データベース構築
init = proc do
	`zenra init`
	User.create('sa2knight' , 'sa2knight' , 'ないと')
	User.create('tomotin' , 'tomotin' , 'ともちん')
	User.create('hetare' , 'hetare' , 'へたれ')
	User.create('unagipai' , 'unagipai' , 'ちゃらさん')
	User.create('worry' , 'worry' , 'ウォーリー')
	Friend.add(1 , 2)
	Friend.add(2 , 1)
	Friend.add(1 , 3)
	Friend.add(3 , 1)
	Friend.add(4 , 1)
	count = 0
	10.times do 
		['sa2knight' , 'tomotin' , 'hetare' , 'unagipai' , 'worry'].each do |username|
			register = Register.new(User.new(username))
			register.with_url = false
			datetime = "2016-02-02 00:00:" + sprintf('%02d' , count)
			count += 1
			register.create_karaoke(
				datetime , 'タイムラインテスト用カラオケ' , 3 ,
				{'name' => 'カラオケ館' , 'branch' => '亀戸店'} ,
				{'brand' => 'JOYSOUND' , 'product' => 'MAX'} ,
			)
			register.attend_karaoke(1000 , 'タイムラインページテスト用attend')
			register.create_history('ハレ晴レユカイ' , '涼宮ハルヒ、朝比奈みくる、長門有希')
		end
	end
end

# 定数定義
url = '/'

# テスト実行
describe 'タイムライン' do
	before(:all , &init)
	it 'タイムラインが正しく表示されるか' do
		login 'sa2knight'
		visit url
		iscontain('友達がいません')
		#タイムラインが１０件表示される
		#友達のカラオケ記録が表示される
		#友達じゃないユーザのは表示されない
	end
	it 'リンクが正常に登録されているか' do
		#ユーザリンクが正常に登録されている
		#カラオケリンクが正常に登録されている
	end
end
