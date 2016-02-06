require_relative './march'

class RankingRoute < March

	# get '/ranking/song' - 楽曲の歌唱回数ランキングを表示
	#---------------------------------------------------------------------
	get '/ranking/song' do
		@songs = Ranking.sang_count
		erb :song_ranking
	end

end
