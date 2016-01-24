require_relative 'rbase'
include Rbase

user = 'user3'
url = '/history'
	
describe 'カラオケ詳細画面' do
	it '概要' do
		login user
		visit url
		iscontain 'ユーザ3さんの歌唱履歴'
		iscontain ['カラオケ3' , '楽曲2-1' , '歌手2' '1']
		iscontain ['カラオケ19'	, '楽曲41-0' , '歌手41' , '-3']
	end
	it 'リンク' do
		login user
		visit url
		have_link '楽曲2-1' , :href => '/song/8'
		have_link '歌手93' , :href => '/artist/94'
	end
end
