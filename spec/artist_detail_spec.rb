require_relative 'rbase'
include Rbase

user = 'user1'
url = '/artist/93'
ids = [277 , 278 , 279]
songs = ['楽曲92-0' , '楽曲92-1' , '楽曲92-2']
	
describe '歌手詳細画面' do
	it '画面表示' do
		login user
		visit url
		iscontain ['歌手92' , 'この歌手の楽曲一覧']
		iscontain songs
	end
	it '楽曲リンク' do
		login user
		visit url
		[0,1,2].each do |i|
			have_link songs[i] , :href => "/song/#{ids[i]}"
		end
	end
	it '集計機能' do
		login user
		visit url
		iscontain [3 , 5 , 14]
	end
end
