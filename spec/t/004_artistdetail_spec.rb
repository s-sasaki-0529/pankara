require_relative '../rbase'
include Rbase

# テスト用データベース構築
init = proc do
	`zenra init`
	User.create('sa2knight' , 'sa2knight' , 'ないと')
	User.create('tomotin' , 'tomotin' , 'ともちん')

	register = Register.new(User.new('sa2knight'))
	register.with_url = false
	karaoke_id = register.create_karaoke(
		'2016-01-04 16:00:00' , '歌手詳細ページテスト用カラオケ' , 3 ,
		{'name' => 'カラオケ館' , 'branch' => '亀戸店'} ,
		{'brand' => 'JOYSOUND' , 'product' => 'MAX'} ,
	)
	register.attend_karaoke(1000 , '歌手詳細ページテスト用attend1')
	5.times {|i| register.create_history('カルマ' , 'BUMP OF CHICKEN') }
	4.times {|i| register.create_history('銀河鉄道' , 'BUMP OF CHICKEN')}
	3.times {|i| register.create_history('stage of the ground' , 'BUMP OF CHICKEN')}

	register = Register.new(User.new('tomotin'))
	register.with_url = false
	register.karaoke = karaoke_id
	register.attend_karaoke(1200 , '歌手詳細ページテスト用attend2')
	3.times {|i| register.create_history('カルマ' , 'BUMP OF CHICKEN') }
	2.times {|i| register.create_history('銀河鉄道' , 'BUMP OF CHICKEN')}
	1.times {|i| register.create_history('stage of the ground' , 'BUMP OF CHICKEN')}
end

# 定数定義
url = '/history'

# テスト実行
describe '歌手詳細ページ' do
	before(&init)
	it '歌手の楽曲一覧が正常に表示されるか' do
		login 'sa2knight'
		visit url
		examine_artistlink 'BUMP OF CHICKEN'
		tables = table_to_hash('artistdetail_table')
		expect(tables.length).to eq 3
		expect(tables[0]['tostring']).to eq 'カルマ,5,8'
		expect(tables[1]['tostring']).to eq '銀河鉄道,4,6'
		expect(tables[2]['tostring']).to eq 'stage of the ground,3,4'
	end
	it 'リンクが正常に登録されているか' do
		songs = ['カルマ' , '銀河鉄道' , 'stage of the ground']
		login 'sa2knight'
		songs.each do |song|
			visit url
			examine_artistlink 'BUMP OF CHICKEN'
			examine_songlink(song , 'BUMP OF CHICKEN')
		end
	end
end
