require_relative 'rbase'
include Rbase

user = 'user1'
url = '/artist/93'
ids = [277 , 278 , 279]
songs = ['楽曲92-0' , '楽曲92-1' , '楽曲92-2']
	
describe '歌手詳細画面' do
	it '画面が正常に表示されるか' do
		login user
		visit url
		iscontain ['歌手92' , 'この歌手の楽曲一覧']
		expect(all(:xpath , "//table/tbody/tr").length).to eq 3
		iscontain songs
	end
	it '曲名のリンクが正常に登録されているか' do
		login user
		visit url
		[0,1,2].each do |i|
			have_link songs[i] , :href => "/song/#{ids[i]}"
		end
	end
	it '曲ごとの歌唱回数が正常に表示されているか' do
		login user
		visit url
		columns = all(:xpath , "//table/tbody/tr[1]/td")
		expect(columns[0].text).to eq songs[0]
		expect(columns[1].text).to eq '3'
		expect(columns[2].text).to eq '14'
	end
end
