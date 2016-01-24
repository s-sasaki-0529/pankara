require_relative 'rbase'
include Rbase

describe '楽曲詳細画面' do
	it '集計表示' do
		login 'user1'
		visit '/song/257'
		iscontain '楽曲85-1 / 歌手85'
		iscontain ['最高: 99.9' , '最低: 10.0' , '平均: 65.1' , '最高: 70.5' , '最低: 10.0']
	end
	it '動画サイト表示' do
		login 'user1'
		visit '/song/257'
		have_link '動画リンク' , :href => 'http://www.nicovideo.jp/watch/sm27583432'
		visit '/song/267'
		expect(page).to have_selector 'iframe[src="https://www.youtube.com/embed/_4P4P1Q-3k4"]'
	end
	it '歌唱履歴表示' do
		songs = [27,25,8,24,9,12,30,11,18]
		login 'user1'
		visit '/song/267'
		songs.each do |song|
			have_link "カラオケ#{song + 1}" , :href => song
		end
	end
end
