require_relative '../rbase'
include Rbase

# テスト用データベース構築
init = proc do
	`zenra init`
	User.create('sa2knight' , 'sa2knight' , 'ないと')
	
	register = Register.new(User.new('sa2knight'))
	register.create_karaoke(
		'2016-01-03 14:00:00' , '楽曲ランキングテスト用カラオケ' , 3 ,
		{'name' => 'カラオケ館' , 'branch' => '亀戸店'} ,
		{'brand' => 'JOYSOUND' , 'product' => 'MAX'} ,
	)
	register.attend_karaoke(1000 , '楽曲ランキングテスト用attend')
	10.times {|i| register.create_history('ロストマン' , 'BUMP OF CHICKEN') }
	5.times {|i| register.create_history('ベル' , 'BUMP OF CHICKEN')}
	register.with_url = false
	30.times {|i| register.create_history("サンプル楽曲#{i}" , "サンプル歌手")}
end

# 定数定義
url = '/ranking/song'

# テスト実行
describe '楽曲ランキング機能' do
	before(&init)
	it 'ランキングが正常に表示される' do
		login 'sa2knight'
		visit url
		tables = table_to_hash('songranking_table')
		iframes = youtube_links
		expect(tables.length).to eq 20
		expect(iframes.length).to eq 2
		expect(tables[0]['tostring']).to eq '1,,ロストマン,BUMP OF CHICKEN,10'
		expect(tables[1]['tostring']).to eq '2,,ベル,BUMP OF CHICKEN,5'
		expect(tables[2]['tostring']).to eq '3,未登録,サンプル楽曲0,サンプル歌手,1'
	end
	it 'リンクが正常に登録されているか' do
		login 'sa2knight'
		visit url
		examine_songlink('ロストマン' , 'BUMP OF CHICKEN' , url)
		examine_artistlink('BUMP OF CHICKEN' , url)
	end
end
