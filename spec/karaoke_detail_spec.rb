require_relative 'rbase'
include Rbase

user = 'user1'
url = '/karaoke/detail/10'
	
describe 'カラオケ詳細画面' do
	it '概要' do
		login user
		visit url
		iscontain ['5.0'	, 'カラオケ店3 店舗0' ,	'JOYSOUND(MAX)'	, 'ユーザ0' , 'ユーザ1' , 'ユーザ4']
		iscontain ['楽曲29-0' , '歌手29' , '-3' , '精密採点DX' , '55.0']
	end
	it 'リンク' do
		login user
		visit url
		have_link 'ユーザ0' , :href => '/user/user0'
		have_link '楽曲6-1' , :href => '/song/20'
		have_link '歌手6' , :href => '/artist/7'
	end
end
