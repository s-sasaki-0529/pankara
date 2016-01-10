require_relative 'rbase'
include Rbase

user = 'user1'
url = '/ranking/song'

describe '楽曲ランキング機能' do
	it 'ランキングが２０行で構成されているか' do
		login user
		visit url
		iscontain '歌唱回数ランキング'
		expect(all('tr').length).to eq 20 + 1
	end
	it '正しく集計されているか' do
		login user
		visit url
		expect(find(:xpath, "//table/tbody/tr[1]/td[5]").text).to eq '15'
	end
	it '曲名、歌手名にリンクが貼られているか' do
		login user
		visit url
		have_link '楽曲0-0' , :href => '/song/1'
		have_link '歌手0' , :href => '/artist/1'
		have_lunk '動画リンク' , :href => 'http://www.nicovideo.jp/watch/sm27583432'
		expect(page).to have_selector 'iframe[src="https://www.youtube.com/embed/_4P4P1Q-3k4"]'
	end
end
