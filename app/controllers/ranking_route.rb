require_relative './march'

class RankingRoute < March

  # get '/ranking/score/?' - 得点ランキングを表示
  # get '/ranking/score/:score_type - 指定した採点モードの得点ランキングを表示
  #--------------------------------------------------------------------
  get '/ranking/score/?' do
    redirect '/ranking/score/1' #取り急ぎデフォルトはJOY全国採点
  end
  get '/ranking/score/:score_type' do
    @scores = Ranking.score(params[:score_type])
    Util.to_json(@scores)
  end

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
