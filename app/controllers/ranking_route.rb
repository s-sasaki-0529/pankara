require_relative './march'

class RankingRoute < March

  # get '/ranking/song' - 楽曲の歌唱回数ランキングを表示
  #---------------------------------------------------------------------
  get '/ranking/song' do
    @songs = Ranking.sang_count
    erb :song_ranking
  end

  # get '/ranking/artist' - 歌手別の歌唱回数ランキングを表示
  #---------------------------------------------------------------------
  get '/ranking/artist' do
    @artists = Ranking.artist_sang_count
    erb :artist_ranking
  end

end
