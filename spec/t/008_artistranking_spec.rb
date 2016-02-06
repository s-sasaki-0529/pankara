require_relative '../rbase'
include Rbase

# テスト用データベース構築
init = proc do
	`zenra init`
	User.create('sa2knight' , 'sa2knight' , 'ないと')
	
	register = Register.new(User.new('sa2knight'))
	register.create_karaoke(
		'2016-01-03 15:00:00' , '歌手別ランキングテスト用カラオケ' , 3 ,
		{'name' => 'カラオケ館' , 'branch' => '亀戸店'} ,
		{'brand' => 'JOYSOUND' , 'product' => 'MAX'} ,
	)
	register.attend_karaoke(1000 , '歌手別ランキングテスト用attend')
	register.with_url = false
	10.times {|i| register.create_history('とっておきの唄' , 'BUMP OF CHICKEN') }
	6.times {|i| register.create_history('糸' , '中島みゆき')}
	5.times {|i| register.create_history('銀の龍の背に乗って' , '中島みゆき')}
	30.times {|i| register.create_history("サンプル楽曲#{i}" , "サンプル歌手#{i}")}
end

# 定数定義
url = '/ranking/artist'

# テスト実行
describe '楽曲ランキング機能' do
	before(:all,&init)
	it 'ランキングが正常に表示される' do
		login 'sa2knight'
		visit url
		tables = table_to_hash('artistranking_table')
		expect(tables.length).to eq 20
		expect(tables[0]['tostring']).to eq '1,中島みゆき,11'
		expect(tables[1]['tostring']).to eq '2,BUMP OF CHICKEN,10'
	end
	it 'リンクが正常に登録されているか' do
		login 'sa2knight'
		visit url
		examine_artistlink('BUMP OF CHICKEN' , url)
		examine_artistlink('中島みゆき' , url)
	end
end
